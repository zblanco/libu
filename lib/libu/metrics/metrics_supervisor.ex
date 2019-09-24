defmodule Libu.Metrics.MetricsSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {Registry, name: Libu.Metrics.CollectorRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Metrics.CollectorSupervisor,  strategy: :one_for_one},
    ], strategy: :one_for_one)
  end
end
