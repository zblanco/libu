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

  TODO:

  - [x] Working conversation appending
  - [x] Cursor stream queries / write-through cache
  - [ ] Re-initialization of dead/timed-out conversations by streaming in from event-store
  - [ ] Implement per-message timeouts/TTLs reset upon access
  - [ ] Ensure the Projection Manager knows when a Projector's TTLs expire and it shuts down
  - [x] Utilize Projection Manager to remove read-bottlenecks that occur through Genserver callbacks

  State of the conversation projection in ETS ordered set:

  key: {message_number, expiration_time}
  value: %Message{...}
  """
  use GenServer, restart: :transient

  alias Libu.Chat.Events.{
    MessageAddedToConversation,
    MessageReadyForQuery,
  }
  alias Libu.Chat.{
    Message,
    Query.ConversationProjectionManager,
    Query.Streaming,
    ConversationProjectorSupervisor,
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
    init_state = %{
      log: :ets.new(:conversation_log, [:ordered_set, :public]),
      registry: :ets.new(:cached_messages, [:set, :public]),
      conversation_id: convo_id,
    }

    ConversationProjectionManager.notify_of_active_conversation(convo_id, init_state)
    Chat.subscribe(convo_id)

    {:ok, init_state, {:continue, :init}}
  end

  def handle_continue(:init, %{conversation_id: convo_id, log: _log, registry: registry} = init_state) do
    message_nos = stream_in_latest_messages(convo_id, init_state)
    # current_time = DateTime.utc_now()
    :ok = register_cache_ttls(message_nos, @default_timeout, registry)
    Process.send_after(self(), :purge, @default_timeout)

    {:noreply, init_state}
  end

  # This is a fat function that could use some cleanup and better error handling and optimizations for larger queries
  def fetch_messages(conversation_id, start_index, end_index) do
    # TODO: ensure actively projecting first
    with false <- ConversationProjectorSupervisor.is_conversation_projecting?(conversation_id) do
      ConversationProjectorSupervisor.start_conversation_projector(conversation_id)
    end
    # fetch stream info, trim range that won't ever return?

    %{cached: cached_messages, uncached: uncached_message_numbers} =
      start_index..end_index
      |> Stream.map(&fetch_if_cached(&1, conversation_id))
      |> Enum.to_list()
      |> Enum.reduce(%{cached: [], uncached: []}, fn num_or_message, %{cached: cm, uncached: umn} = acc ->
        case num_or_message do
          {:ok, message} -> %{acc | cached: [message | cm]}
          msg_number     -> %{acc | uncached: [msg_number | umn]}
        end
      end)

    uncached_message_numbers = Enum.reverse(uncached_message_numbers)

    first_uncached = List.first(uncached_message_numbers)
    last_uncached = List.last(uncached_message_numbers)

    %{log: _log, registry: registry} = tables = ConversationProjectionManager.tables_of_projector(conversation_id)

    messages_from_storage =
      stream_in_messages(conversation_id, tables, first_uncached..last_uncached |> Enum.to_list)

    cached_message_map =
      cached_messages
      |> Enum.into(%{}, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    messages =
      messages_from_storage
      |> Enum.into(cached_message_map, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    :ok = register_cache_ttls(Map.keys(messages), @default_timeout, registry)

    {:ok, Map.values(messages)}
  end

  def fetch_message(conversation_id, message_number) do
    # also ensure it's a real conversation...
    with false <- ConversationProjectorSupervisor.is_conversation_projecting?(conversation_id) do
      ConversationProjectorSupervisor.start_conversation_projector(conversation_id)
    end

    case fetch_if_cached(message_number, conversation_id) do
      {:ok, _cached_message} = return ->
        return

      _message_number ->
        %{log: _log, registry: registry} = tables = ConversationProjectionManager.tables_of_projector(conversation_id)

        message =
          case stream_in_messages(conversation_id, tables, [message_number]) do
            [%Message{} = message] -> message
            [] = messages          -> List.first(messages)
          end

        _msg_no = register_as_cached(message_number, @default_timeout, registry)

        {:ok, message}
    end
  end

  defp fetch_if_cached(message_number, conversation_id) do
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

  defp stream_in_messages(conversation_id, %{log: log, registry: registry}, message_numbers) do
    conversation_id
    |> conversation_stream_uuid
    |> EventStreaming.stream_forward(List.first(message_numbers), Kernel.length(message_numbers))
    |> Stream.filter(&Streaming.is_message_event?(&1))
    |> Stream.map(&Streaming.build_message(&1))
    |> Stream.map(&persist_message_from_stream(log, &1))
    |> Stream.map(&register_as_cached(&1, @default_timeout, registry))
    |> Enum.to_list()
  end

  defp stream_in_latest_messages(conversation_id, %{log: log, registry: registry}, max_no_of_messages \\ 20) do
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
          _                               <- register_as_cached(message.message_number, @default_timeout, registry),
          query_ready_event               <- MessageReadyForQuery.new(message),
         :ok                              <- Messaging.publish(query_ready_event, Chat.topic(convo_id))
    do
      {:noreply, state}
    else
      _error -> {:noreply, state}
    end
  end

  # def handle_info(:purge, %{log: log, registry: registry} = tables) do
  #   # go through cache registry to find expired
  #   # remove from log & registry
  #   {:noreply, tables}
  # end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp register_as_cached(%Message{message_number: message_no} = message, timeout, cache_registry) do
    register_as_cached(message_no, timeout, cache_registry)
    message
  end

  defp register_as_cached(message_no, timeout, cache_registry) when is_integer(message_no) do
    :ets.insert(cache_registry, {message_no, timeout})
    message_no
  end

  defp register_cache_ttls(message_nos, timeout, cache_registry) do
    Enum.map(message_nos, &register_as_cached(&1, timeout, cache_registry))
    :ok
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
end
