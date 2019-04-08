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

  # def publish_message(params, [form: true]), do: PublishMessage.new(params, form: true)
  # def publish_message(params \\ %{}) do
  #   with {:ok, command} <- PublishMessage.new(params) do
  #     command
  #     |> PublishMessage.
  #   end
  # end


  def publish_message(message_attrs, conversation_id) do
    with {:ok, message} <- Message.new(message_attrs, conversation_id) do
      Communication
    end
    # Find Conversation
    # Deliver message to conversation process
  end

  def publish_message(message_attrs), do: initiate_conversation(message_attrs)

  @doc """
  Creates a new conversation of which other users can reply to.
  """
  def initiate_conversation(message_attrs) do
    with {:ok, message}      <- Message.new(message_attrs),
         {:ok, conversation} <- Conversation.start(message)
    do
      conversation
      |> ConversationStarted.new()
      |> notify_subscribers()

      {:ok, conversation}
    end
  end

  def notify_subscribers(event) do
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic, {__MODULE__, event})
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic <> "#{event.conversation_id}", {__MODULE__, event})
    {:ok, event}
  end

end
