defmodule Libu.Chat.Events.MessageAddedToConversation do
  @moduledoc """
  Emitted from Chat when a message is published.
  """
  defstruct [
    :conversation_id,
    :publisher_id,
    :message,
    :parent_message_id,
  ]
end
