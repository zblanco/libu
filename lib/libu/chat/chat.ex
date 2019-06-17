defmodule Libu.Chat do
  @moduledoc """
  Users can publish messages to conversations.
  The first published message starts a conversation.
  A conversation is a top level thread or channel for which more messages are posted.
  Anyone else can reply to the conversation linking their message to the parent.

  This is mostly an excuse to play with the Registry and Dynamic Supervisors.
  We might only store state transiently within ETS initially.

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

  # def publish_message(params, [form: true]), do: PublishMessage.new(params, form: true)
  # def publish_message(params \\ %{}) do
  #   with {:ok, command} <- PublishMessage.new(params) do
  #     command
  #     |> PublishMessage.
  #   end
  # end


  def publish_message(%{} = msg_attrs, conversation_id) do
    with {:ok, message} <- Message.new(msg_attrs, conversation_id) do
      ConversationProcess.add_to(message)
    end
    # Find Conversation
    # Deliver message to conversation process
  end

  def publish_message(msg_attrs), do: initiate_conversation(msg_attrs)

  @doc """
  Creates a new conversation of which other users can reply to.
  """
  def initiate_conversation(message_attrs) do
    with {:ok, message} <- Message.new(message_attrs),
         conversation   <- Conversation.start(message)
    do
      # conversation
      # |> ConversationStarted.new()
      # |> notify_subscribers()

      {:ok, conversation}
    end
  end

  def demo_conversations() do
    [
      demo_conversation(),
      demo_conversation(),
    ]
  end

  def get_conversation(_), do: demo_conversation()

  defp demo_conversation() do
    {:ok, msg}  = Message.new(%{publisher_id: "doops", body: "liveview is pretty neat"})
    {:ok, msg2} = Message.new(%{publisher_id: "doops", body: "tailwind is smooth"})
    Conversation.start(msg) |> Conversation.add_to(msg2)
  end

  def notify_subscribers(event) do
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic, {__MODULE__, event})
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic <> "#{event.conversation_id}", {__MODULE__, event})
    {:ok, event}
  end

end
