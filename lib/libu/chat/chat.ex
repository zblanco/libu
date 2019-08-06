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
    Commands.InitiateConversation,
    Commands.AddToConversation,
    Commands.EndConversation,
    Router,
    Query,
  }
  alias Libu.Messaging

  def topic(), do: inspect(__MODULE__)

  def subscribe, do: Messaging.subscribe(topic())

  def subscribe(conversation_id), do:
    Messaging.subscribe("#{topic()}:#{conversation_id}")

  @doc """
  Appends your message to an existing conversation.
  """
  def add_to_conversation(params, [form: true]), do: AddToConversation.new(params, form: true)
  def add_to_conversation(params \\ %{}) do
    with {:ok, cmd} <- AddToConversation.new(params),
         :ok        <- Router.dispatch(cmd, consistency: :strong) do
      Query.conversation(cmd.conversation_id)
    else
      error -> error
    end
  end

  @doc """
  Initiates a new conversation of which other users can add to.
  """
  def initiate_conversation(params, [form: true]), do: InitiateConversation.new(params, form: true)
  def initiate_conversation(initial_conversation_attrs) do
    with {:ok, cmd} <- InitiateConversation.new(initial_conversation_attrs),
         :ok        <- Router.dispatch(cmd, consistency: :strong) do
      Query.conversation(cmd.conversation_id)
    else
      error -> error
    end
  end

  def end_conversation(conversation_id, reason)
  when is_binary(conversation_id)
  and is_binary(reason) do
    with {:ok, cmd} <- EndConversation.new(%{conversation_id: conversation_id, reason: reason}) do
      Router.dispatch(cmd, consistency: :strong)
    else
      error -> error
    end
  end

  defdelegate active_conversations, to: Query
end
