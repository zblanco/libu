defmodule Libu.Chat.Conversation do
  @moduledoc """
  A simple container of messages.
  """
  alias Libu.Chat.{
    Commands.InitiateConversation,
    Commands.AddToConversation,
    Commands.EndConversation,
    Events.ConversationStarted,
    Events.MessageAddedToConversation,
    Events.ConversationEnded,
  }
  alias __MODULE__

  defstruct [
    :id,
    :messages,
    :title,
  ]

  def execute(%Conversation{id: nil}, %InitiateConversation{} = cmd) do
    %ConversationStarted{
      conversation_id: cmd.conversation_id,
      title: cmd.title,
      initiated_by: cmd.initiator_name,
      initiated_by_id: cmd.initiator_id,
      initial_message: cmd.message,
      started_on: DateTime.utc_now(),
    }
  end

  def execute(%Conversation{id: id, messages: messages}, %AddToConversation{} = cmd) when not is_nil(id) do
    %MessageAddedToConversation{
      conversation_id: cmd.conversation_id,
      publisher_id: cmd.publisher_id,
      publisher_name: cmd.publisher_name,
      message: cmd.message,
      message_number: length(messages) + 1,
      added_on: DateTime.utc_now(),
    }
  end

  def execute(%Conversation{id: id}, %EndConversation{} = cmd) when not is_nil(id) do
    %ConversationEnded{
      conversation_id: cmd.conversation_id,
      reason: cmd.reason,
    }
  end

  def apply(%Conversation{} = conv,
    %ConversationStarted{conversation_id: conv_id, initial_message: initial_message})
  do
    %Conversation{ conv |
      id: conv_id,
      messages: [initial_message],
    }
  end

  def apply(%Conversation{messages: previous_messages} = conv,
    %MessageAddedToConversation{conversation_id: conv_id, message: message})
  do
    %Conversation{ conv |
      id: conv_id,
      messages: [message | previous_messages],
    }
  end
end
