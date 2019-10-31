defmodule Libu.Chat.Query.ConversationDatabaseProjector do
  @moduledoc """
  Uses Commanded Ecto Projections to build a query model in Postgres for a Conversation.
  """
  use Commanded.Projections.Ecto,
    application: Libu.Chat.Commanded,
    repo: Libu.Repo,
    name: Atom.to_string(__MODULE__)

  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
    MessageReadyForQuery,
    ActiveConversationAdded,
  }
  alias Libu.Messaging
  alias Libu.Chat
  alias Libu.Chat.Query.Schemas.{Conversation, Message}
  alias Libu.Chat.Query
  alias Libu.Chat.Query.ConversationCache

  project(%ConversationStarted{} = convo_started, %{event_id: event_id}, fn multi ->
    multi
    |> Ecto.Multi.insert(:conversation, Conversation.new(convo_started))
    |> Ecto.Multi.insert(:message, Message.new(convo_started, event_id))
    |> Ecto.Multi.run(:cache_message, fn _repo, %{message: message} ->
      ConversationCache.cache_message(message)

      MessageReadyForQuery.new(message)
      |> Messaging.publish(Chat.topic(message.conversation_id))

      ActiveConversationAdded.new(convo_started)
      |> Messaging.publish(Chat.topic())

      {:ok, message}
    end)
  end)

  project(%MessageAddedToConversation{} = message_added, %{event_id: event_id}, fn multi ->
    multi
    |> Ecto.Multi.update(:updated_conversation, Conversation.changes_for_message_added(message_added))
    |> Ecto.Multi.insert(:message, Message.new(message_added, event_id))
    |> Ecto.Multi.run(:cache_message, fn _repo, %{message: message} ->
      ConversationCache.cache_message(message)

      event = MessageReadyForQuery.new(message)
      Messaging.publish(event, Chat.topic(message.conversation_id))
      Messaging.publish(event, Chat.topic())

      {:ok, message}
    end)
  end)
end
