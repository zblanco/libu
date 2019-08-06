defmodule Libu.Chat.EventHandlers.MessageAddedToConversation do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :strong,
    start_from: :current

  alias Libu.Chat.Events.MessageAddedToConversation
  alias Libu.Messaging
  alias Libu.Chat.Persistence
  alias Libu.Chat

  def handle(%MessageAddedToConversation{conversation_id: convo_id} = event, _metadata) do
    with :ok <- Persistence.add_to_conversation(event) do
      Messaging.publish(event, Chat.topic() <> convo_id)
      :ok
    else
      error -> error
    end
  end
end
