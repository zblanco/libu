defmodule Libu.Chat.EventHandlers.ConversationStarted do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.
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
    Messaging.publish(event, Chat.topic() <> convo_id)
    with :ok <- Projections.prepare_conversation(event) do
      :ok
    else
      error -> error
    end
  end
end
