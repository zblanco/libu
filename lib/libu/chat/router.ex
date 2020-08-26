defmodule Libu.Chat.Router do
  @moduledoc """
  Commanded router to direct commands to the right aggregates.
  """
  use Commanded.Commands.Router, application: Libu.Chat.Commanded
  alias Libu.Chat.{
    Commands.InitiateConversation,
    Commands.AddToConversation,
    Commands.EndConversation,
    Conversation,
  }

  identify Conversation, by: :conversation_id, prefix: "conversation-"

  dispatch [
    InitiateConversation,
    AddToConversation,
    EndConversation,
  ], to: Conversation

end
