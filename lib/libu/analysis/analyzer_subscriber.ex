defmodule Libu.Analysis.AnalyzerSubscriber do
  @doc """
  A process to consume `analysis_result_produced` events for a given session with an analyzer module.

  An analyzer subscriber's job is to call the persistence module to store the recent results.

  This process should be Dynamically Supervised under a Dynamic Supervisor existing under or linked to the SessionProcess.
  As the analyzers are toggled on or off, these Subscriber processes will be activated/deactivated.
  """
  use GenServer
  alias Libu.Analysis.Events.AnalysisResultProduced

  def start_link(session_id, analyzer) do
    GenServer.start_link(__MODULE__, {session_id, analyzer}, name: __MODULE__)
  end

  def init({session_id, analyzer}) do
    Phoenix.PubSub.subscribe(Libu.PubSub, "analysis_results_produced:#{session_id}:#{analyzer}")
    {:ok, %{analyzer: analyzer, session_id: session_id}}
  end

  def handle_info(AnalysisResultProduced, _) do
    {:noreply, }
  end

  def subscribe(), do: :stuff
end
