defmodule Libu.Chat.Query.Streaming do
  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
    ConversationEnded,
  }
  alias Libu.Chat.Message
  alias Libu.Chat.EventStore, as: EventStreamer

  def build_message(%EventStore.RecordedEvent{} = event) do
    Message.new(event)
  end

  def stream_chat_log_forward(), do: EventStreamer.stream_all_forward()

  # def stream_conversation_backward(convo_id, amount),
  #   do: EventStreamer.stream_backward(conversation_stream_uuid(convo_id), :end, amount)

  defp conversation_stream_uuid(conversation_id), do: "conversation-#{conversation_id}"

  def is_message_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
      event_type ==
      "Elixir.Libu.Chat.Events.ConversationStarted"
      || "Elixir.Libu.Chat.Events.MessageAddedToConversation"
  end

  def is_start_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
    event_type == "Elixir.Libu.Chat.Events.ConversationStarted"
  end

  def is_end_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
    event_type == "Elixir.Libu.Chat.Events.ConversationEnded"
  end

  def stream_uuid_of_recorded_event(
    %EventStore.RecordedEvent{stream_uuid: stream_uuid}) do
      stream_uuid
  end

  def is_start_or_end_event?(
    %EventStore.RecordedEvent{event_type: event_type}) do
    event_type ==
      "Elixir.Libu.Chat.Events.ConversationStarted"
      || "Elixir.Libu.Chat.Events.ConversationEnded"
  end
end
