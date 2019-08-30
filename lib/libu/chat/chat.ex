defmodule Libu.Chat do
  @moduledoc """
  Chat supports basic chat-rooms called "conversations".

  We can initiate a conversation, add more messages to the conversation, and end a conversation.

  The plan is to compose some of the Text Analysis features by aggregating live metrics about a conversation based on the text content.

  We're currently using Commanded for CQRS event-sourcing runtime support.

  Commanded and the Postgres EventStore adapter lets us stream together the state of a conversation at any point in time and/or react in soft-real-time.

  This makes it a good candidate for projecting in-memory read models for both core chat features and live metrics.

  Commanded is used for the core command routing and event aggregations to streams.

  We're using Commanded Event Handlers to communicate with more custom OTP + ETS processes for the in-memory read models.

  The event handlers will publish to our `Messaging` context using Pub Sub to let reactive UI like LiveView know when to fetch new state from our read-model.

  We're doing this by caching to ETS optimistically based on any given users view of a conversation.

  The conversation Projector streams only messages it needs from the event-store with a Time To Live (TTL) on each message reset upon client-viewing.

  We dynamically supervise a Conversation View Sessions which holds the scroll state of viewable messages.

  This Conversation View Session maintains an index of currently viewed messages by the user to
    communicate with the Conversation Projector which streams in messages ad-hoc.
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

  def initiate_test_convo, do: initiate_conversation(%{
    initiator_id: "Doops", initial_message: UUID.uuid4()
  })

  @doc """
  Initiates a new conversation of which other users can add to.
  """
  def initiate_conversation(params, [form: true]), do: InitiateConversation.new(params, form: true)
  def initiate_conversation(initial_conversation_attrs) do
    with {:ok, cmd} <- InitiateConversation.new(initial_conversation_attrs),
         :ok        <- Router.dispatch(cmd, consistency: :strong) do
      # Query.conversation(cmd.conversation_id)
      :ok
    else
      error -> error
    end
  end

  @doc """
  Ends a conversation for whatever reason.

  TODO: Authorization and/or rule-based conversation ends.
  """
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
