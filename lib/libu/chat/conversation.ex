defmodule Libu.Chat.Conversation do
  @moduledoc """
  A Process which represents a tree of related messages.
  """
  alias Libu.Chat.Message
  alias __MODULE__

  defstruct [
    :id,
    :messages,
    :initiated_on,
    :initiated_by,
    :last_activity,
  ]

  def start(%Message{conversation_id: nil} = initial_message) do
    %Conversation{
      id: UUID.uuid4(),
      messages: [initial_message],
      initiated_by: initial_message.publisher_id,
      initiated_on: DateTime.utc_now(),
      last_activity: DateTime.utc_now(),
    }
  end

  def publish_message(%Conversation{messages: messages} = conv, %Message{} = message) do
    %Conversation{ conv |
      messages: messages ++ message,
      last_activity: message.published_on,
    }
  end
end
