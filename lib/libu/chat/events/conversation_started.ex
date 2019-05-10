defmodule Libu.Chat.Events.ConversationStarted do
  @moduledoc """
  """
  alias Libu.Chat.Conversation
  defstruct [
    :conversation_id,
    :initiated_on,
    :initiated_by,
    :initial_message,
  ]

  def new(%Conversation{messages: [initial_msg | _]} = conv) do
    %__MODULE__{
      conversation_id: conv.id,
      initiated_on: conv.intiated_on,
      initiated_by: conv.initated_by,
      initial_message: initial_msg,
    }
  end
end
