defmodule Libu.Chat.ConversationProjector do
  @moduledoc """
  Transient Process responsible for maintaining an ETS table of a conversation.

  We put new messages to the top of the stack deprecating old messages at a timeout since last queried.

  When all messages time-out the process shuts down.

  We re-cache from the event-store when messages that have been timed-out are requeried placing them back in their ordered location.

  Within the Projector we keep a cache_state that maintains a map of message_number => {message_id, ttl}
    - we use this cache_state to know when to re-stream old messages

  A separate Chat Session process communicates with a conversation_projector regarding it's query start/end indexes.

  What this projector ought to do:

  * Stream in messages from the EventStore
    * For every message's event_id
  *

  TODO:

  - [x] Working conversation appending
  - [x] Cursor stream queries / write-through cache
  - [ ] Re-initialization of dead/timed-out conversations by streaming in from event-store
  - [ ] Implement per-message timeouts/TTLs reset upon access
  - [ ] Utilize Projection Manager to remove read-bottlenecks that occur through Genserver callbacks

  State of the conversation projection in ETS ordered set:

  key: {message_number, expiration_time}
  value: %Message{...}
  """
  use GenServer, restart: :transient

  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
    ConversationEnded,
    MessageReadyForQuery,
  }
  alias Libu.Chat.{
    Message,
    Query.ConversationProjectionManager,
    Query.Streaming,
    ConversationProjectionSupervisor,
  }
  alias Libu.{Chat, Messaging}
  alias Libu.Chat.EventStore, as: EventStreaming

  @default_timeout :timer.minutes(30)

  def via(convo_id) when is_binary(convo_id) do
    {:via, Registry, {Libu.Chat.ConversationProjectionRegistry, {__MODULE__, convo_id}}}
  end
  def via(_convo_id), do: :non_binary_id

  def child_spec(convo_id) do
    %{
      id: {__MODULE__, convo_id},
      start: {__MODULE__, :start_link, [convo_id]},
      restart: :temporary,
    }
  end

  def start_link(convo_id) do
    GenServer.start_link(
      __MODULE__,
      convo_id,
      name: via(convo_id)
    )
  end

  def start(convo_id) do
    DynamicSupervisor.start_child(
      ConversationProjectorSupervisor,
      {__MODULE__, convo_id}
    )
  end

  def init(convo_id) do
    tables = %{
      log: :ets.new(:conversation_log, [:ordered_set, :public]),
      registry: :ets.new(:cached_messages, [:set, :public])
    }

    ConversationProjectionManager.notify_of_active_conversation(convo_id, tables)
    Chat.subscribe(convo_id)

    {:ok, %{tables | conversation_id: convo_id}, {:continue, :init}}
  end

  def handle_continue(:init, %{conversation_id: convo_id, log: log, registry: registry} = init_state) do
    message_nos = stream_in_latest_messages(convo_id, log, 20)
    current_time = DateTime.utc_now()
    :ok = register_cache_ttls(message_nos, @default_timeout, registry)
    schedule_purge(convo_id, @default_timeout)

    {:noreply, init_state}
  end

  def schedule_purge(conversation_id, timeout) do
    Process.send_after(via(conversation_id), :purge, timeout)
  end

  def fetch_messages(conversation_id, start_index, end_index) do

    %{cached: cached_messages, uncached: uncached_message_numbers} =
      start_index..end_index
      |> Stream.map(&fetch_if_cached(&1, conversation_id))
      |> Enum.group_by(fn
        {:ok, _message} -> :cached
        _msg_number     -> :uncached
      end)

    first_uncached   = List.first(uncached_message_numbers)
    last_uncached    = List.last(uncached_message_numbers)
    %{log: _log, registry: registry} = tables = ConversationProjectionManager.tables_of_projector(conversation_id)

    messages_from_storage =
      stream_in_messages(conversation_id, tables, first_uncached..last_uncached)

    cached_message_map =
      cached_messages
      |> Enum.into(%{}, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    messages =
      messages_from_storage
      |> Enum.into(cached_message_map, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    :ok = register_cache_ttls(Map.keys(messages), @default_timeout, registry)

    {:ok, Map.values(messages)}
  end

  defp fetch_if_cached(message_number, conversation_id)
  when is_binary(conversation_id) do

    %{registry: registry, log: log} =
      ConversationProjectionManager.tables_of_projector(conversation_id)

    with true <- is_cached?(message_number, registry),
         {:ok, _message} = response <- fetch_message_from_log(log, message_number)
    do
      response
    else
      _ -> message_number
    end
  end

  defp fetch_message_from_log(log, message_number) do
    case :ets.lookup(log, message_number) do
      [{_msg_no, message}] -> message
      _ -> {:error, :message_not_found_in_log}
    end
  end

  def stream_in_messages(conversation_id, %{log: log, registry: registry}, message_numbers) do
    conversation_id
    |> conversation_stream_uuid
    |> EventStreaming.stream_forward(List.first(message_numbers), Kernel.length(message_numbers))
    |> Stream.filter(&Streaming.is_message_event?(&1))
    |> Stream.map(&Streaming.build_message(&1))
    |> Stream.map(&persist_message_from_stream(log, &1))
    |> Stream.map(&register_as_cached(&1, @default_timeout, registry))
    |> Enum.to_list()
  end

  def stream_in_latest_messages(conversation_id, %{log: log, registry: registry}, max_no_of_messages \\ 20) do
    conversation_id
    |> conversation_stream_uuid()
    |> EventStreaming.stream_backward(:end, max_no_of_messages)
    |> Stream.filter(&Streaming.is_message_event?(&1))
    |> Stream.map(&Streaming.build_message(&1))
    |> Stream.map(&persist_message_from_stream(log, &1))
    |> Stream.map(fn %Message{message_number: message_number} -> message_number end)
    |> Stream.map(&register_as_cached(&1, @default_timeout, registry))
    |> Enum.to_list()
  end

  def handle_info(%MessageAddedToConversation{conversation_id: convo_id} = event, state) do
    with  message                         <- Message.new(event),
          %{log: log, registry: registry} <- ConversationProjectionManager.tables_of_projector(convo_id),
          _msg                            <- persist_message_from_stream(log, message),
          true                            <- register_as_cached(message.message_number, @default_timeout, registry),
          query_ready_event               <- MessageReadyForQuery.new(message),
         :ok                              <- Messaging.publish(query_ready_event, Chat.topic(convo_id))
    do
      IO.puts "Conversation Projection Updated with new message"
      {:noreply, state}
    else
      _error -> {:noreply, state}
    end
  end

  def handle_info(:purge, %{log: log, registry: registry} = tables) do
    # go through cache registry to find expired
    # remove from log & registry
    {:noreply, tables}
  end

  defp register_as_cached(%Message{message_number: message_no} = message, timeout, cache_registry) do
    register_as_cached(message_no, timeout, cache_registry)
    message
  end

  defp register_as_cached(message_no, timeout, cache_registry) when is_integer(message_no) do
    :ets.insert(cache_registry, {message_no, timeout})
  end

  defp register_cache_ttls([] = message_nos, timeout, cache_registry) do
    Enum.map(message_nos, &register_as_cached(&1, timeout, cache_registry))
  end

  defp persist_message_from_stream(tid, %Message{} = msg) do
    insert_message(tid, msg)
    msg
  end

  defp insert_message(tid, %Message{} = msg) do
    :ets.insert(tid, {msg.message_number, msg})
  end

  defp is_cached?(message_id, registry) do
    case :ets.lookup(registry, message_id) do
      [{^message_id, _ttl}] -> true
      _ -> false
    end
  end

  defp conversation_stream_uuid(conversation_id), do: "conversation-#{conversation_id}"

  # def add_message_to_projection(convo_id, %Message{} = message) do
  #   # TODO: If not alive, restart and refresh with last 20 messages or so
  #   # GenServer.call(via(convo_id), {:add_message_to_projection, message})
  #   call(convo_id, {:add_message_to_projection, message})
  # end

  # def get_messages(convo_id) when is_binary(convo_id) do
  #   GenServer.call(via(convo_id), {:get_messages, []})
  #   # Consider moving this responsibility from the Projector to the Query context
  #   # Instead make the projector only responsible for preparing messages in ETS
  # end

  # def handle_call({:add_message_to_projection, message}, _from, %{cached_messages: %{} = cached_messages} = state) do
  #   %{tid: tid} = state
  #   %Message{published_on: timestamp_key} = message
  #   # check if message isn't already cached (we'll need the index in the conversation stream in our Message struct)
  #   with true <- :ets.insert(tid, {timestamp_key, message}) do
  #     new_state = %{state | cached_messages: %{cached_messages | message.index => DateTime.utc_now}}
  #     {:reply, {:ok, message}, new_state}
  #   else
  #     _ -> {:error, :issue_building_conversation_read_model}
  #   end
  # end

  # # TODO: Cursor based conversation to re-fetch deprecated messages as needed
  # def handle_call({:get_messages, []}, _from, %{tid: tid} = state) do
  #   results =
  #     :ets.match(tid, :"$1") # Just get it all
  #     |> Enum.map(fn [{_msg_timestamp, msg}] -> msg end)
  #   {:reply, results, state}
  # end

  # def handle_call({:get_messages, [start_index: start_index, end_index: end_index]}, _from,
  #   %{tid: tid, cached_messages: cache_state} = state)
  # do
  #   # check against the cached message state within the projector
  #   # maintain a count of messages of a conversation within the projector so we know not to try and stream messages that don't exist
  #   # for each index value between start and end, does our cache_state have it ready?
  #   # if not, stream that message in from the store, set the index in our cache with the ttl
  #   # once all messages in the index are ready in the read model, notify as such
  #   results =
  #     :ets.match(tid, {:""}) # match keys within an index bound equal to or within the start

  #     |> Enum.map(fn [{_msg_timestamp, msg}] -> msg end)
  #   {:reply, results, state}
  # end

  # def handle_call({:get_messages, [start_time: _start, end_time: _end] = args}, _from, %{tid: tid} = state) do
  #   results = do_get_messages(tid, args)
  #   {:reply, results, state}
  # end

  # # TODO: Change to index keys instead of timestamp keys
  # def do_get_messages(tid, [start_time: start_time, end_time: end_time]) do
  #   messages = []
  #   {next_key, messages} =
  #     case :ets.lookup(tid, start_time) do
  #       [{_msg_timestamp, message}] ->
  #         {:ets.next(tid, start_time), List.insert_at(messages, -1, message)}
  #       [] ->
  #         {:ets.next(tid, start_time), messages}
  #     end
  #   fetch_messages_from_table(tid, [key: next_key, end_key: end_time], messages)
  # end

  # defp fetch_messages_from_table(_tid, [key: :"$end_of_table", end_key: _end_key], messages) do
  #   messages
  # end

  # defp fetch_messages_from_table(tid, [key: key, end_key: end_key], messages) do
  #   if key >= end_key do
  #     messages
  #   else
  #     [{_msg_timestamp, msg}] = :ets.lookup(tid, key)
  #     messages = List.insert_at(messages, -1, msg)
  #     next_key = :ets.next(tid, key)
  #     fetch_messages_from_table(tid, [key: next_key, end_key: end_key], messages)
  #   end
  # end

  # defp call(convo_id, action) do
  #   via = via(convo_id)

  #   pid =
  #     case GenServer.whereis(via) do
  #       nil ->
  #         {:ok, pid} = __MODULE__.start(via)
  #         pid
  #       pid ->
  #         pid
  #     end
  #   GenServer.call(pid, action)
  # end
end
