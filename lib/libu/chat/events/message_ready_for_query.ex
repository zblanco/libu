defmodule Libu.Chat.Events.MessageReadyForQuery do
  @moduledoc """
  Emitted from Chat when a message can be fetched from the Projector.
  """
  alias Libu.Chat.Message
  defstruct [
    :conversation_id,
    :event_id,
    :message_number,
  ]

  def new(%Message{} = msg) do
    %__MODULE__{
      conversation_id: msg.conversation_id,
      event_id: msg.event_id,
      message_number: msg.message_number,
    }
  end
end
