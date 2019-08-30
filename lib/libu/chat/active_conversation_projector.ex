defmodule Libu.Chat.ActiveConversationProjector do
  @moduledoc """
  Manages the ETS table of Active Conversations for the Active Conversation read-model.

  TODO: Consider moving the ETS concerns to a separate module.
  """
  use GenServer

  alias Libu.Chat.{
    Events.ConversationStarted,
    Events.ConversationEnded,
    Events.ActiveConversationAdded,
    Message,
  }
  alias Libu.{Chat, Messaging}

  def init(_opts) do
    :ets.new(:active_conversations, [:set, :protected, :named_table])
    Chat.subscribe()
    IO.puts(":active_conversations table created")
    {:ok, [], {:continue, :init}}
  end

  def handle_continue(:init, _opts) do
    rebuild_state()
    {:noreply, %{}} # TODO: maintain stream versions, last seen events, and think about snapshots
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def handle_event(event) do
    GenServer.call(__MODULE__, {:project, event})
  end

  def handle_call({:project, %ConversationEnded{conversation_id: convo_id}}, _from, state) do
    with true <- delete_conversation(convo_id),
    do: {:reply, :ok, state}, else: (_ -> {:reply, :error})
  end

  def handle_call({:project, %ConversationStarted{} = event}, _from, state) do
    with {:ok, :message_projected} <- insert_message_from_event(event) do
      {:reply, :ok, state}
    else
      error -> {:reply, error}
    end
  end

  def handle_info(%ConversationStarted{} = event, state) do
    with :ok                <- insert_message_from_event(event),
         active_convo_added <- ActiveConversationAdded.new(event),
         :ok                <- Messaging.publish(active_convo_added, Chat.topic())
    do
      IO.puts "Publishing ActiveConversationAdded"
      {:noreply, state}
    else
      _error -> {:noreply, state}
    end
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "ActiveConversationProjector")
    {:noreply, state}
  end

  defp rebuild_state() do
    EventStore.stream_all_forward()
    |> Stream.filter(&is_start_or_end_event?(&1)) # remove unrelated events from $all
    |> Stream.uniq_by(&stream_uuid_of_recorded_event(&1)) # cancel out starts with ends
    |> Stream.filter(&is_start_event?(&1)) # remove ended events
    |> Stream.map(&build_message(&1)) # convert to message
    |> Stream.each(&persist_message_from_stream(&1)) # push into ets
    |> Enum.to_list()
  end

  defp build_message(%EventStore.RecordedEvent{data: event}) do
    Message.new(event)
  end

  defp is_start_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
    event_type == "Elixir.Libu.Chat.Events.ConversationStarted"
  end

  defp stream_uuid_of_recorded_event(
    %EventStore.RecordedEvent{stream_uuid: stream_uuid}) do
      stream_uuid
  end

  defp is_start_or_end_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
    event_type ==
      "Elixir.Libu.Chat.Events.ConversationStarted"
      || "Elixir.Libu.Chat.Events.ConversationEnded"
  end

  defp persist_message_from_stream(%Message{} = msg) do
    insert_message(msg)
    msg
  end

  defp insert_message_from_event(event) do
    with msg  <- Message.new(event),
         true <- insert_message(msg)
    do
      :ok
    else
      error -> {:error, error}
    end
  end

  defp insert_message(%Message{conversation_id: convo_id} = msg) do
    :ets.insert_new(:active_conversations, {convo_id, msg})
  end

  defp delete_conversation(convo_id),
    do: :ets.delete(:active_conversations, convo_id)
end
