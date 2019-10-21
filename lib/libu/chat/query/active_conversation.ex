defmodule Libu.Chat.Query.ActiveConversation do
  @moduledoc """
  Read model representation of an active conversation.

  Projected from an event log to be used by web and other contexts.
  """
  alias Libu.Chat.Events.{
    ConversationStarted,
  }
  alias Libu.Chat.Message
  alias EventStore.RecordedEvent

  defstruct [
    :conversation_id, # stream identity of the conversation
    :title,
    :initial_message, # the first message published (convo_started)
    :message_count, # counter
    :latest_activity, # timestamp
    :latest_message, # latest message published (message added)
  ]

  def new(recorded_event) do
    %RecordedEvent{
      data: %ConversationStarted{
        conversation_id: convo_id,
        title: title,
      } = _event,
    } = recorded_event

    message = Message.new(recorded_event)

    %__MODULE__{
      conversation_id: convo_id,
      title: title,
      initial_message: message,
      message_count: 1,
      latest_activity: recorded_event.created_at,
      latest_message: message,
    }
  end

  def set_latest_message(%__MODULE__{} = active_convo, %Message{} = msg) do
    %__MODULE__{active_convo |
      latest_message: msg,
      latest_activity: msg.published_on,
      message_count: active_convo.message_count + 1,
    }
  end
end
