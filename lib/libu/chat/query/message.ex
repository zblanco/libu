defmodule Libu.Chat.Message do
  @moduledoc """
  A message published as part of a conversation.

  This is used as a read-model representation converted to from events by projectors.
  """
  defstruct [
    :conversation_id,
    :event_id, # the unique event id that the message correlates with in the event store
    :message_number, # the count of messages in a convo, index starting at 1
    :publisher_id, # publisher id (Github id)
    :publisher, # publisher public name
    :body,
    :published_on,
  ]

  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
  }

  def new(%EventStore.RecordedEvent{event_type: event_type} = recorded_event)
  when event_type in [
       "Elixir.Libu.Chat.Events.ConversationStarted",
       "Elixir.Libu.Chat.Events.MessageAddedToConversation"]
  do
    recorded_event.data
    |> new()
    |> put_recorded_event_params(recorded_event)
  end

  def new(%ConversationStarted{
    conversation_id: convo_id,
    initiated_by: publisher_id,
    initial_message: body,
    started_on: start_time,
  }) do
    %__MODULE__{
      conversation_id: convo_id,
      publisher_id: publisher_id,
      body: body,
      published_on: start_time,
      message_number: 1,
    }
  end

  def new(%MessageAddedToConversation{
    conversation_id: convo_id,
    publisher_id: publisher_id,
    message: body,
    message_number: msg_no,
    added_on: added_on,
  }) do
    %__MODULE__{
      conversation_id: convo_id,
      publisher_id: publisher_id,
      body: body,
      published_on: added_on,
      message_number: msg_no,
    }
  end

  defp put_recorded_event_params(%__MODULE__{} = message, recorded_event) do
    %EventStore.RecordedEvent{
      event_id: event_id,
      stream_version: message_number,
    } = recorded_event

    %__MODULE__{message |
      event_id: event_id,
      message_number: message_number,
    }
  end
end
