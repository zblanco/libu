defmodule Libu.Analysis.AnalyzerSubscriber do
  @doc """
  A process to consume `analysis_result_produced` events for a given session with an analyzer module.

  AnalysisResultProduced = message
  analysis_result_produced:my_session_id:analyzer

  An analyzer subscriber's job is to call the persistence module to store the recent results.

  This process should be Dynamically Supervised under a Dynamic Supervisor existing under or linked to the SessionProcess.
  As the analyzers are toggled on or off, these Subscriber processes will be activated/deactivated.
  """
  use GenServer
  alias Libu.Analysis.Events.AnalysisResultProduced
  alias Libu.Messaging
  alias Libu.Analysis.AnalyzerSubscriberSupervisor

  def via(session_id, analyzer) do
    {:via, Registry, {
      Libu.Analysis.AnalyzerSubscriberRegistry,
      {session_id, analyzer}}}
  end

  def start_link(session_id, analyzer) do
    GenServer.start_link(__MODULE__, {session_id, analyzer}, name: __MODULE__)
  end

  def init({session_id, analyzer}) do
    Messaging.subscribe(topic_for_analyzer(analyzer, session_id))
    {:ok, %{analyzer: analyzer, session_id: session_id}}
  end

  # Should the Analzyer Subscriber know that it's supervised via a Dynamic Supervisor? Maybe not...
  def setup(session_id, analyzer) do
    DynamicSupervisor.start_child(
      Libu.Analysis.AnalyzerSubscriberSupervisor,
      {__MODULE__, analyzer: analyzer, session_id: session_id}
    )
  end

  def deactivate(session_id, analyzer) do
    via(session_id, analyzer)
    |> GenServer.whereis()
    |> (fn pid -> DynamicSupervisor.terminate_child(
      AnalyzerSubscriberSupervisor, pid)
    end).()
  end

  defp topic_for_analyzer(analyzer_module, session_id) do
    "analysis_results_produced:#{session_id}:#{analyzer_module}"
  end

  def handle_info(%AnalysisResultProduced{} = event, subscription) do
    IO.inspect(event, label: "analysis result produced:: ")
    # Persist to a ETS under a tuple key of {session_id, analyzer}
    {:noreply, subscription}
  end


end
