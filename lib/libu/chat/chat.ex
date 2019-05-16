defmodule Libu.Chat do
  @moduledoc """
  Users can publish messages to conversations.
  The first published message starts a conversation.
  This conversation is a process.
  Anyone else can reply to the conversation linking their message to the parent.

  This is mostly an excuse to play with the Registry and Dynamic Supervisors.
  We might only store state transiently within ETS for initially.

  Features that would be neat:

    * Lazily stream messages as a person is scrolling through a page
    * Dynamic rendering of nested messages
    * Event Sourced Persistence
    * Dynamic, many-to-many contextual linking
    * ConversationSupervisor pool
    * Persistence Contract
    * Websocket API
    * FIFO Command Handling

  """
  alias Libu.Chat.{
    Events.ConversationStarted,
    Events.MessagePublished,
    Message,
    Conversation,
    ConversationProcess,
    ConversationSupervisor,
  }

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Libu.PubSub, @topic)
  end

  def subscribe(conversation_id) do
    Phoenix.PubSub.subscribe(Libu.PubSub, @topic <> "#{conversation_id}")
  end
end
