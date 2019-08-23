defmodule Libu.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Libu.Repo,
      LibuWeb.Endpoint,

      {Registry, name: Libu.Analysis.SessionRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Analysis.SessionSupervisor,  strategy: :one_for_one},
      {Registry, name: Libu.Analysis.SubscriberSupervisorRegistry, keys: :unique},

      {Libu.Chat.ProjectionSupervisor, name: Libu.Chat.ProjectionSupervisor},
      {Registry, name: Libu.Chat.ConversationProjectionRegistry, keys: :unique},
      {Registry, name: Libu.Chat.ConversationSessionRegistry, keys: :unique},
      {DynamicSupervisor, name: Libu.Chat.ConversationSessionSupervisor,  strategy: :one_for_one},
    ]

    opts = [strategy: :one_for_one, name: Libu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LibuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
