defmodule Libu.Chat.ActiveConversationProjector do
  @moduledoc """
  Manages the ETS table of Active Conversations for the Active Conversation read-model.

  TODO:
    * Subscribe to EventStore directly instead of using Pub Sub (so we access RecordedEvents for everything)
    * Switch to build state with `%ActiveConversation{}` instead of Message.
  """
  use GenServer

  alias Libu.Chat.{
    Events.ConversationStarted,
    # Events.ConversationEnded,
    Events.ActiveConversationAdded,
    Events.MessageAddedToConversation,
    Message,
    Query.Streaming,
    Query.ActiveConversation,
  }
  alias Libu.{Chat, Messaging}

  def init(_opts) do
    :ets.new(:active_conversations, [:set, :protected, :named_table])
    Chat.subscribe()
    {:ok, [], {:continue, :init}}
  end

  def handle_continue(:init, _opts) do
    rebuild_state()
    {:noreply, %{}} # TODO: maintain stream versions, last seen events, and think about snapshots
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def fetch_active_conversation(conversation_id) do
    case :ets.lookup(:active_conversations, conversation_id) do
      [{_convo_id, active_convo}] -> {:ok, active_convo}
      _ -> {:error, :conversation_not_found}
    end
  end

  def fetch_active_conversations() do
    :ets.tab2list(:active_conversations)
    |> Enum.map(fn {_convo_id, convo} -> convo end)
  end

  def handle_info(%ConversationStarted{conversation_id: convo_id} = event, state) do
    with active_convo <-
      Streaming.stream_conversation_forward(convo_id, 1)
      |> Enum.to_list()
      |> List.first()
      |> ActiveConversation.new()
    do
      insert(active_convo)

      ActiveConversationAdded.new(event)
      |> Messaging.publish(Chat.topic())
    end

    {:noreply, state}
  end

  def handle_info(%MessageAddedToConversation{conversation_id: convo_id} = event, state) do
    with {:ok, active_convo} <- fetch_active_conversation(convo_id),
         message             <- Message.new(event),
         updated_convo       <- ActiveConversation.set_latest_message(active_convo, message)
    do
      insert(updated_convo)
    end

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp rebuild_state() do
    Streaming.stream_chat_log_forward()
    |> Stream.filter(&Streaming.is_start_or_end_event?(&1))
    |> Stream.uniq_by(&Streaming.stream_uuid_of_recorded_event(&1)) # removes end events
    |> Stream.filter(&Streaming.is_start_event?(&1))
    |> Stream.map(&Streaming.build_active_conversation(&1))
    |> Enum.to_list()
    |> Enum.map(fn %{conversation_id: convo_id} = active_convo ->
      %{active_convo | latest_message: fetch_latest_message_of_conversation(convo_id)}
    end)
    |> Enum.each(&insert(&1))
  end

  defp fetch_latest_message_of_conversation(conversation_id) do
    # While this works, it's not likely querying the event store once per conversation is the best option
    # We should figure out a better way to accumulate an Active Conversation when streaming through the log.
    Streaming.stream_conversation_backward(conversation_id, 1)
    |> Stream.filter(&Streaming.is_message_event?(&1))
    |> Stream.map(&Streaming.build_message(&1))
    |> Enum.to_list()
    |> List.first()
  end

  defp insert(%ActiveConversation{conversation_id: convo_id} = convo) do
    :ets.insert(:active_conversations, {convo_id, convo})
  end

  defp delete_conversation(convo_id) do
    :ets.delete(:active_conversations, convo_id)
  end
end
