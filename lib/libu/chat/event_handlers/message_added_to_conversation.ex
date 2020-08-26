defmodule Libu.Chat.EventHandlers.MessageAddedToConversation do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current,
    application: Libu.Chat.Commanded

  alias Libu.Chat.Events.MessageAddedToConversation
  alias Libu.Messaging
  alias Libu.Chat

  def handle(%MessageAddedToConversation{conversation_id: convo_id} = event, _metadata) do
    Messaging.publish(event, Chat.topic(convo_id))
    :ok
  end
end
