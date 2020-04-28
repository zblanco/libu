defmodule Libu.Messaging.MessagingSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {Phoenix.PubSub, [name: Libu.Messaging.PubSub, adapter: Phoenix.PubSub.PG2]},
    ], strategy: :one_for_one)
  end
end

