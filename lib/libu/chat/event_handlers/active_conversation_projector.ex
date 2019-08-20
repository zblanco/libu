defmodule Libu.Chat.EventHandlers.ActiveConversationProjector do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.

  Here we start from `:origin` in this global event handler to then spawn a conversation-specific event-handler to maintain a projection.

  We spawn the event_handlers under a dynamic supervisor.

  TODO: Create an active_conversation_projection event_handler with a custom init for ets
  TODO: Create a ConversationProjectionManager that spawns an event_handler for each conversation
    - Spawn under a DynamicSupervisor with start_child
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :strong,
    start_from: :origin

  alias Libu.Chat.{
    Events.ConversationStarted,
    Message,
  }

  def init do
    :ets.new(:active_conversations, [:set, :protected, :named_table])
    :ok
  end

  def handle(%ConversationStarted{conversation_id: convo_id} = event, _metadata) do
    with initial_message <- Message.new(event),
         true            <- :ets.insert_new(:active_conversations, {convo_id, initial_message})
    do
      :ok
    else
      _ -> :error
    end
  end
end
