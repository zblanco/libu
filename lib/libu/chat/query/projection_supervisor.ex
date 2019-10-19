defmodule Libu.Chat.ProjectionSupervisor do
  use Supervisor

  alias Libu.Chat.EventHandlers.{
    ConversationProjectionManager,
    ConversationStarted,
    MessageAddedToConversation,
  }
  alias Libu.Chat.{
    ActiveConversationProjector,
    Query.ConversationProjectionManager,
  }

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {ActiveConversationProjector, [name: ActiveConversationProjector]},
      ConversationStarted,
      MessageAddedToConversation,
      {DynamicSupervisor, [
        name: Libu.Chat.ConversationProjectorSupervisor,
        strategy: :one_for_one
      ]},
      {ConversationProjectionManager, [name: ConversationProjectionManager]},
    ], strategy: :one_for_one)
  end
end
