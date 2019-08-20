defmodule Libu.Chat.ProjectionSupervisor do
  use Supervisor

  alias Libu.Chat.EventHandlers.{
    ActiveConversationProjector,
    ConversationProjectionManager,
  }

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      ActiveConversationProjector,
      ConversationProjectionManager,
    ], strategy: :one_for_one)
  end
end
