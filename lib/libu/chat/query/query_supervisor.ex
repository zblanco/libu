defmodule Libu.Chat.Query.QuerySupervisor do
  use Supervisor

  alias Libu.Chat.EventHandlers.{
    ConversationCacheManager,
    ConversationStarted,
    MessageAddedToConversation,
  }
  alias Libu.Chat.{
    Query.ConversationCacheManager,
    Query.ConversationCacheSupervisor,
    Query.ConversationDatabaseProjector,
  }

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {ConversationCacheSupervisor, [name: ConversationCacheSupervisor]},
      {ConversationCacheManager, [name: ConversationCacheManager]},
      ConversationDatabaseProjector,
      ConversationStarted,
      MessageAddedToConversation,
    ], strategy: :one_for_one)
  end
end
