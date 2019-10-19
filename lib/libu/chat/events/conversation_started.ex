defmodule Libu.Chat.Events.ConversationStarted do
  defstruct [
    :conversation_id,
    :initiated_by,
    :initial_message,
    :started_on,
  ]
end
