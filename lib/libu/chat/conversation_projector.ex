defmodule Libu.Chat.ConversationProjector do
  @moduledoc """
  Process responsible for maintaining an ordered set ETS table of a conversation.

  We put new messages to the top of the stack deprecating old messages at a timeout since last queried.

  We re-cache from the event-store when messages that have been timed-out are requeried placing them back in their ordered location.

  We can either: maintain in-memory projections of all active conversations (cleaning up old conversations and recreating only if needed)
    or
  Try and be clever and only maintain the actual messages that have been read recently, responding to queries by streaming in events
   from the eventstore and rebuilding the state to persist to ets on demand.

  We can be clever here with the querying by keying the messages with a tuple: {message_id, timestamp}
    - we might need to keep a different table with message timeouts by id so we know the full picture without loading message bodies in memory
    - we use the message availability state to re-stream old messages as needed

  A separate Chat Session process can keep

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

  def via(convo_id) when is_binary(convo_id) do
    {:via, Registry, {Libu.Chat.ConversationProjectionRegistry, convo_id}}
  end

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

    {:noreply, %{tid: tid, conversation_id: convo_id, cached_messages: %{}}}
  end

  def add_message_to_projection(convo_id, %Message{} = message) do
    # TODO: If not alive, restart and refresh with last 20 messages or so
    GenServer.call(via(convo_id), {:add_message_to_projection, message})
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
end
