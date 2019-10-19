defmodule Libu.Chat.EventHandlers.ConversationEnded do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.

  Responsibilities:

  * Publish to our Messaging context (pub sub)
  * Notify projection layer to deactivate the conversation in our Read models.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current,
    application: Libu.Chat.Commanded

  alias Libu.{
    Messaging,
    Chat,
    Chat.Events.ConversationEnded
  }

  def handle(%ConversationEnded{conversation_id: convo_id} = event, _metadata) do
    Messaging.publish(event, Chat.topic(convo_id))
    :ok
  end
end
