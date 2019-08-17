defmodule Libu.Chat.EventHandlers.ConversationStarted do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.

  For our projections we could do one of the following:

  * Subscribe to the messaging context where messages are potentially un-ordered
  * Directly coordinate from this global event handler (may bottle-neck)
  * Start from `:origin` in this global event handler to then spawn a conversation-specific event-handler for every started conversation
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :strong,
    start_from: :current

  alias Libu.Chat.Events.ConversationStarted
  alias Libu.Messaging
  alias Libu.Chat
  alias Libu.Chat.Projections

  def handle(%ConversationStarted{conversation_id: convo_id} = event, _metadata) do
    Messaging.publish(event, Chat.topic() <> ":" <> convo_id)
    with :ok <- Projections.handle_event(event) do
      :ok
    else
      error -> error
    end
  end
end
