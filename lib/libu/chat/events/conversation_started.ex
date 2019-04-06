defmodule Libu.Chat.Events.ConversationStarted do
  @moduledoc """
  """
  defstruct [
    :conversation_id,
    :initiated_on,
    :initiated_by,
    :initial_message,
  ]
end
