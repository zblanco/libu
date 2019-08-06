defmodule Libu.Chat.EventHandlers.ConversationEnded do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.

  Responsibilities:

  * Publish to our Messaging context (pub sub)
  * Notify projection layer to deactivate the conversation in our Read models.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :strong,
    start_from: :current

  alias Libu.{
    Messaging,
    Chat,
    Chat.Projections,
    Chat.Events.ConversationEnded
  }

  def handle(%ConversationEnded{conversation_id: convo_id} = event, _metadata) do
    with :ok <- Projections.deactivate_conversation(event) do
      Messaging.publish(event, Chat.topic() <> convo_id)
      :ok
    else
      error -> error
    end
  end
end
