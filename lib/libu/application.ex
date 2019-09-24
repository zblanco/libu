defmodule Libu.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Libu.Repo,
      LibuWeb.Endpoint,
      {Libu.Metrics.MetricsSupervisor, []},
      {Libu.Chat.ChatSupervisor, []},
      {Libu.Analysis.AnalysisSupervisor, []},
    ]

    # Libu.Metrics.setup()

    opts = [strategy: :one_for_one, name: Libu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LibuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
