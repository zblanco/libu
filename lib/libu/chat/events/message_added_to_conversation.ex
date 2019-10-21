defmodule Libu.Chat.Events.MessageAddedToConversation do
  @moduledoc """
  Emitted from Chat when a message is published.
  """
  defstruct [
    :conversation_id,
    :publisher_id,
    :publisher_name,
    :message,
    :message_number,
    :added_on,
  ]
end
