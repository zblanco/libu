defmodule Libu.Chat.EventHandlers.ConversationProjectionManager do
  @moduledoc """
  Spawns a Conversation Projector process if one doesn't already exist, then hands it a new message.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current

  alias Libu.Chat.{
    Events.ConversationStarted,
    Message,
    ConversationProjector,
  }

  alias Libu.{Chat, Messaging}

  def handle(%ConversationStarted{conversation_id: convo_id} = event, _metadata) do
    with {:ok, _pid} <- ConversationProjector.start(convo_id),
         first_msg   <- Message.new(event),
         {:ok, _msg} <- ConversationProjector.add_message_to_projection(convo_id, first_msg)
    do
      Messaging.publish(event, Chat.topic() <> convo_id)
      :ok
    else
      error -> error
    end
  end
end
