defmodule Libu.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Libu.Repo,
      LibuWeb.Endpoint,
      # {Registry, name: Libu.Chat.ConversationRegistry, keys: :unique},
      # {Registry, name: Libu.Analysis.SessionRegistry,  keys: :unique},
      # {DynamicSupervisor, name: Libu.Chat.ConversationSupervisor, strategy: :one_for_one},
      # {DynamicSupervisor, name: Libu.Analysis.SessionSupervisor,  strategy: :one_for_one},
    ]

    opts = [strategy: :one_for_one, name: Libu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LibuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
