defmodule Libu.Chat do
  @moduledoc """
  Users can publish messages to conversations.
  The first published message starts a conversation.
  A conversation is a top level thread or channel for which more messages are posted.
  Anyone else can reply to the conversation linking their message to the parent.

  We're currently using Commanded for CQRS event-sourcing runtime support.

  What we're doing different is an in-memory read-model (projections).
  We're doing this by caching to ETS optimistically based on any given users view of a conversation.
  We dynamically supervise a Conversation View Session which holds the scroll state of viewable messages to ensure
    messages in a conversation are prepared in ETS with a time-out or memory maximum.
  This means we need to stream from the eventstore but only if the message isn't cached.
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
