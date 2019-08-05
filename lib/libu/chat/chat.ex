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

  If we're to make an event-sourced chat system, what would that require?

    * route `message_published` events to the right aggregate process
      * restart aggregate process if not available (use Registry)
    * persistent event-store (PostgresQL EventStore probably)
  """
  alias Libu.Chat.{
    Events.ConversationStarted,
    Events.MessagePublished,
    Message,
    Conversation,
    ConversationProcess,
    ConversationSupervisor,
  }
  alias Libu.Messaging

  defp topic(), do: inspect(__MODULE__)

  def subscribe, do: Messaging.subscribe(topic())

  def subscribe(conversation_id), do:
    Messaging.subscribe("#{topic()}:#{conversation_id}")


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
      conversation
      |> ConversationStarted.new()
      |> Messaging.publish(topic())

      {:ok, conversation}
    end
  end

  def active_conversations do

  end

  def demo_conversations() do
    [
      demo_conversation(),
    ]
  end

  def get_conversation(_), do: demo_conversation()

  defp demo_conversation() do
    {:ok, msg}  = Message.new(%{publisher_id: "doops", body: "liveview is pretty neat"})
    {:ok, msg2} = Message.new(%{publisher_id: "doops", body: "tailwind is smooth"})

    Conversation.start(msg)
    |> IO.inspect(label: "message before add_to")
    |> Conversation.add_to(msg2)
    |> IO.inspect(label: "messages after add_to")
  end
end
