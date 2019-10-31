defmodule Libu.Chat.ChatSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {Libu.Chat.Commanded, []},
      {Libu.Chat.Query.QuerySupervisor, name: Libu.Chat.Query.QuerySupervisor},
      {Registry, name: Libu.Chat.ConversationCacheRegistry, keys: :unique},
      {Registry, name: Libu.Chat.ConversationSessionRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Chat.ConversationSessionSupervisor,  strategy: :one_for_one},
    ], strategy: :one_for_one)
  end
end
