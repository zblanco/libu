defmodule Libu.Chat.EventHandlers.ConversationStarted do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current,
    application: Libu.Chat.Commanded

  alias Libu.Chat.Events.ConversationStarted
  alias Libu.Chat.ConversationProjector
  alias Libu.Messaging
  alias Libu.Chat

  def handle(%ConversationStarted{conversation_id: convo_id} = event, _metadata) do
    ConversationProjector.start(convo_id)
    Messaging.publish(event, Chat.topic(convo_id))
    Messaging.publish(event, Chat.topic())
    :ok
  end
end
