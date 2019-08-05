defmodule Libu.Chat.Events.MessageAddedToConversation do
  @moduledoc """
  Emitted from Chat when a message is published.
  """
  defstruct [
    :publisher_id,
    :message_body,
    :published_on,
    :parent_message_id,
  ]
end
