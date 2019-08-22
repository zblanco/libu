defmodule Libu.Chat.ProjectionSupervisor do
  use Supervisor

  alias Libu.Chat.EventHandlers.{
    ConversationProjectionManager,
  }
  alias Libu.Chat.ActiveConversationProjector

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {ActiveConversationProjector, [name: ActiveConversationProjector]},
      ConversationProjectionManager,
      {DynamicSupervisor, [
        name: Libu.Chat.ConversationProjectorSupervisor,
        strategy: :one_for_one
      ]},
    ], strategy: :one_for_one)
  end
end
