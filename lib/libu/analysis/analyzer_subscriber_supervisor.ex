defmodule Libu.Analysis.AnalyzerSubscriberSupervisor do
  @moduledoc """
  Supervises Analyzer Subscribers for a given analysis session

  Started with a new Analysis session.
  """
  use DynamicSupervisor

  alias Libu.Analysis.AnalyzerSubscriber


  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SubscriberSupervisorRegistry, session_id}}
  end

  def start_link(session_id) do
    DynamicSupervisor.start_link(__MODULE__, session_id, name: via(session_id))
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_subscriber(session_id, analyzer_module) do
    identifier = {session_id, analyzer_module}

    DynamicSupervisor.start_child(
      __MODULE__,
      %{
        id: identifier,
        start: {AnalyzerSubscriber, :start_link, [identifier]},
        type: :worker,
        restart: :permanent,
      }
    )
  end

  def toggle_subscriber(analyzer_module) do
    # if active, terminate, else start subscriber for analyzer module
  end
end
