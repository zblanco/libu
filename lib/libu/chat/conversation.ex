defmodule Libu.Chat.Conversation do
  @moduledoc """
  A simple container of messages.
  """
  alias Libu.Chat.{
    Commands.InitiateConversation,
    Commands.AddToConversation,
    Events.ConversationStarted,
    Events.MessageAddedToConversation,
    Events.ConversationEnded,
  }
  alias __MODULE__

  defstruct [
    :id,
    :messages,
    :initiated_on,
    :initiated_by,
    :last_activity,
  ]

  #  def start(%Message{parent_id: nil} = initial_message) do
  #   %Conversation{
  #     id: UUID.uuid4(),
  #     messages: [initial_message],
  #     initiated_by: initial_message.publisher_id,
  #     initiated_on: DateTime.utc_now(),
  #     last_activity: DateTime.utc_now(),
  #   }
  # end
  def start(_, %InitiateConversation{} = cmd) do
    %ConversationStarted{
      conversation_id: cmd.conversation_id,
      initiated_by: cmd.initiator_id,
      initiated_on: DateTime.utc_now(),
      initial_message: cmd.initial_message,
    }
  end

  def add_to(%Conversation{} = conv, %AddToConversation{} = cmd) do
    %MessageAddedToConversation{
      conversation_id: conv.id,
      added_on: DateTime.utc_now(),
      message: cmd.message,
      message_publisher: cmd.publisher,
    }
  end

  def add_to(%Conversation{messages: messages} = conv, %Message{} = new_message) do
    %Conversation{ conv |
      messages: [messages | new_message],
      last_activity: new_message.published_on,
    }
  end

  # def execute(%Conversation{} = conv, %PublishMessage{} = publish_message) do
  #   %MessagePublished{

  #   }
  # end

  # def execute(%Conversation{} = conv, %EndConversation{} = publish_message) do
  #   %ConversationEnded{

  #   }
  # end
end
