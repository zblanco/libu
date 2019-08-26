defmodule Libu.Chat.ConversationProjector do
  @moduledoc """
  Transient Process with a TTL responsible for maintaining an ordered set ETS table of a conversation.

  We put new messages to the top of the stack deprecating old messages at a timeout since last queried.

  When all messages time-out the process shuts down.

  We re-cache from the event-store when messages that have been timed-out are requeried placing them back in their ordered location.

  Within the Projector we keep a cache_state that maintains a map of message_number => {message_id, ttl}
    - we use this cache_state to know when to re-stream old messages

  A separate Chat Session process communicates with a conversation_projector regarding it's query start/end indexes.

  TODO:

  - [x] Working conversation appending
  - [ ] Cursor stream queries / write-through cache
  - [ ] Re-initialization of dead/timed-out conversations by streaming in from event-store
  - [ ] Implement per-message timeouts/TTLs reset upon access

  State of the conversation projection in ETS ordered set:

  key: {message_number, expiration_time}
  value: %Message{...}
  """
  use GenServer, restart: :transient

  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
    ConversationEnded,
  }
  alias Libu.Chat.Message

  # @default_timeout :timer.minutes(60)

  def via(convo_id) when is_binary(convo_id) do
    {:via, Registry, {Libu.Chat.ConversationProjectionRegistry, convo_id}}
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
      Libu.Chat.ConversationProjectorSupervisor,
      {__MODULE__, convo_id}
    )
  end

  def init(convo_id) do
    {:ok, convo_id, {:continue, :init}}
  end

  def handle_continue(:init, convo_id) do
    tid = :ets.new(:conversation_log, [:ordered_set])
    # Should we automatically stream in the last 10 or so messages?
    latest_messages = stream_in_latest_messages(convo_id, tid, 20)
    :ok = subscribe_to_eventstore(convo_id) # subscribe to ensure new messages are appended
    {:noreply, %{
      tid: tid,
      conversation_id: convo_id,
      cached_messages: MapSet.new()
    }}
  end

  def stream_in_latest_messages(conversation_id, tid, max_no_of_messages) do
    # conversation_id
    # |> conversation_stream_uuid()
    # |> EventStore.stream_backward(:stream_end, max_no_of_messages) # We'll need a stream_backward capability in EventStore to do what we want!
    # |> Stream.filter(&is_start_or_added_event?(&1))
    # |> Stream.map(&build_message(&1))
    # |> Stream.each(&persist_messages_from_stream(tid, &1))
    # |> Enum.to_list()
    []
  end

  def stream_in_messages(conversation_id, tid, start_index, end_index) do
    # stream in messages from the
  end

  # Definitely break out into a projection utilities module of some kind
  defp build_message(%EventStore.RecordedEvent{data: event}) do
    Message.new(event)
  end

  defp conversation_stream_uuid(conversation_id), do: "conversation-#{conversation_id}"

  def add_message_to_projection(convo_id, %Message{} = message) do
    # TODO: If not alive, restart and refresh with last 20 messages or so
    # GenServer.call(via(convo_id), {:add_message_to_projection, message})
    call(convo_id, {:add_message_to_projection, message})
  end

  def get_messages(convo_id) when is_binary(convo_id) do
    GenServer.call(via(convo_id), {:get_messages, []})
    # Consider moving this responsibility from the Projector to the Query context
    # Instead make the projector only responsible for preparing messages in ETS
  end

  def handle_call({:add_message_to_projection, message}, _from, %{cached_messages: %{} = cached_messages} = state) do
    %{tid: tid} = state
    %Message{published_on: timestamp_key} = message
    # check if message isn't already cached (we'll need the index in the conversation stream in our Message struct)
    with true <- :ets.insert(tid, {timestamp_key, message}) do
      new_state = %{state | cached_messages: %{cached_messages | message.index => DateTime.utc_now}}
      {:reply, {:ok, message}, new_state}
    else
      _ -> {:error, :issue_building_conversation_read_model}
    end
  end

  # TODO: Cursor based conversation to re-fetch deprecated messages as needed
  def handle_call({:get_messages, []}, _from, %{tid: tid} = state) do
    results =
      :ets.match(tid, :"$1") # Just get it all
      |> Enum.map(fn [{_msg_timestamp, msg}] -> msg end)
    {:reply, results, state}
  end

  def handle_call(
    {:get_messages, [start_index: start_index, end_index: end_index]},
    from,
    %{tid: tid, cached_messages: cache_state} = state
  ) do
    # check against the cached message state within the projector
    # maintain a count of messages of a conversation within the projector so we know not to try and stream messages that don't exist
    # for each index value between start and end, does our cache_state have it ready?
    # if not, stream that message in from the store, set the index in our cache with the ttl
    # once all messages in the index are ready in the read model, notify as such
    results =
      :ets.match(tid, {:""}) # match keys within an index bound equal to or within the start

      |> Enum.map(fn [{_msg_timestamp, msg}] -> msg end)
    {:reply, results, state}
  end

  def handle_call({:get_messages, [start_time: _start, end_time: _end] = args}, _from, %{tid: tid} = state) do
    results = do_get_messages(tid, args)
    {:reply, results, state}
  end

  # TODO: Change to index keys instead of timestamp keys
  def do_get_messages(tid, [start_time: start_time, end_time: end_time]) do
    messages = []
    {next_key, messages} =
      case :ets.lookup(tid, start_time) do
        [{_msg_timestamp, message}] ->
          {:ets.next(tid, start_time), List.insert_at(messages, -1, message)}
        [] ->
          {:ets.next(tid, start_time), messages}
      end
    fetch_messages_from_table(tid, [key: next_key, end_key: end_time], messages)
  end

  defp fetch_messages_from_table(_tid, [key: :"$end_of_table", end_key: _end_key], messages) do
    messages
  end

  defp fetch_messages_from_table(tid, [key: key, end_key: end_key], messages) do
    if key >= end_key do
      messages
    else
      [{_msg_timestamp, msg}] = :ets.lookup(tid, key)
      messages = List.insert_at(messages, -1, msg)
      next_key = :ets.next(tid, key)
      fetch_messages_from_table(tid, [key: next_key, end_key: end_key], messages)
    end
  end

  defp call(convo_id, action) do
    via = via(convo_id)

    pid =
      case GenServer.whereis(via) do
        nil ->
          {:ok, pid} = __MODULE__.start(via)
          pid
        pid ->
          pid
      end
    GenServer.call(pid, action)
  end
end
