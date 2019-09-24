defmodule Libu.Analysis.AnalysisSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Registry, name: Libu.Analysis.SessionRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Analysis.SessionSupervisor,  strategy: :one_for_one},
      {Libu.Analysis.QueueSupervisor, []},
      {Libu.Analysis.Broadway, []},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
