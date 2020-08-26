defmodule Libu.Chat.Events.ConversationStarted do
  defstruct [
    :conversation_id,
    :initiated_by,
    :initiated_by_id,
    :initial_message,
    :title,
    :started_on,
  ]
end
