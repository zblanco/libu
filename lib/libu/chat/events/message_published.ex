defmodule Libu.Chat.Events.MessagePublished do
  @moduledoc """
  """
  defstruct [
    :publisher_id,
    :message_body,
    :published_on,
    :parent_message_id,
  ]
end
