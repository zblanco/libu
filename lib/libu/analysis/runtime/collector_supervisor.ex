defmodule Libu.Analysis.CollectorSupervisor do
  @moduledoc """
  Started with a SessionProcess to supervise Collection Processes that consume session events to prepare useful metrics.
  """
  use DynamicSupervisor

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, {__MODULE__, session_id}}}
  end

  def collector_via(collector_module, session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, {collector_module, session_id}}}
  end

  def start_link(session_id) do
    DynamicSupervisor.start_link(__MODULE__, session_id, name: via(session_id))
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_collector(collector_module, session_id) do
    DynamicSupervisor.start_child(
      via(session_id),
      {collector_module, session_id}
    )
  end

  def stop_collector(collector_module, session_id) do
    collector_via(collector_module, session_id)
    |> GenServer.whereis()
    |> (fn pid -> DynamicSupervisor.terminate_child(via(session_id), pid) end).()
  end

end
