defmodule Libu.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Libu.Repo,
      LibuWeb.Endpoint,
      {Registry, keys: :unique, name: Registry.Conversations},
      {DynamicSupervisor, strategy: :one_for_one, name: Libu.Chat.ConversationSupervisor},
    ]

    opts = [strategy: :one_for_one, name: Libu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LibuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
