defmodule Libu.Chat.ChatSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      # {Libu.Chat.EventStore, []},
      {Libu.Chat.Commanded, []},
      {Libu.Chat.ProjectionSupervisor, name: Libu.Chat.ProjectionSupervisor},
      {Registry, name: Libu.Chat.ConversationProjectionRegistry, keys: :unique},
      {Registry, name: Libu.Chat.ConversationSessionRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Chat.ConversationSessionSupervisor,  strategy: :one_for_one},
    ], strategy: :one_for_one)
  end
end
