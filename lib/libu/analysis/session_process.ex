defmodule Libu.Analysis.SessionProcess do
  @moduledoc """
  Holds a set of Analyzer modules that are enqueued analysis jobs when a TextChanged event occurs.

  Using a Dynamic Supervisor we maintain a 1:1 Analysis Session with a LiveView.

  In an ideal world the LiveView connects and agrees to a send us Operational Transform events based on edits.
  From there we rebuild the text into it's latest version stored in ets.
  Each configured analyzer is queued analysis jobs based on the full text state.
  When the analyzer is done, the result is resolved back to the session state then stored in ETS.
    - Late results that have been preceded by another job of the same analyzer with fresher state are discarded.
  Whenever an analysis change is made, we publish to a pub sub where our LiveView client can be notified to refetch the analysis results from ETS.
  ```

  Basic Lifecycle:

  * @first live view mount: start an analysis session under a Dynamic Supervisor with the initial state.
  * @liveview de-mount: kill the analysis session (temporary)
    * or keep hot for a period of time (transient) - worthwhile only if we have Identity Sessions.
  * @text change: queue analysis jobs to the configured analyzers in the session,
  * @job completion: update and return the result in the `analysis` map.
  * @analyzer configuration change: update the set of Analyzer modules to queue jobs to, cancel all jobs to removed Analyzers for a session
  """
  use GenServer
  alias Libu.Analysis.{
    Session,
    Events.TextChanged,
    AnalyzerSubscriber,
    Query,
  }

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, session_id}}
  end

  def child_spec(%Session{id: session_id} = session) do
    %{
      id: {__MODULE__, session_id},
      start: {__MODULE__, :start_link, [session]},
      restart: :temporary,
    }
  end

  def start_link(%Session{id: session_id} = session) do
    GenServer.start_link(
      __MODULE__,
      session,
      name: via(session_id)
    )
  end

  def start(session) do
    DynamicSupervisor.start_child(
      Libu.Analysis.SessionSupervisor,
      {__MODULE__, session}
    )
  end

  def init(session),
    do: {:ok, session, {:continue, :init}}

  def handle_continue(:init, session) do
    # tid = :ets.new()
    setup_subscriptions(session)
    {:noreply, session}
  end

  def analyze(_session_id, text) when is_nil(text), do: {:error, :nothing_to_analyze}
  def analyze(session_id, text) when is_binary(text) do
    GenServer.call(via(session_id), {:analyze, text})
  end

  def toggle_analyzer(session_id, analyzer) when is_atom(analyzer) do
    GenServer.call(via(session_id), {:toggle_analyzer, analyzer})
  end

  def handle_call({:analyze, text}, _from, session) do
    session = Session.set_text(session, text)
    event = TextChanged.new(session)
    call_analyzers(session, event)
    {:reply, :ok, session}
  end

  def handle_call({:toggle_analyzer, analyzer}, %Session{} = session) do

    # Terminate the subscriber process
    session =
      case available_analyzer?(analyzer) do
        :ok -> Session.toggle_analyzer(session, analyzer)
      end

      # terminate_subscriber(session_id, analyzer)

    {:reply, :ok, session}
  end

  defp available_analyzer?(analyzer) do
    Map.has_key?(Session.analyzers_by_key(), analyzer)
  end

  # We should publish text changed to a set of analyzer subscribers instead
  # Each subscriber can call the Analyzer
  defp call_analyzers(%Session{active_analyzers: analyzer_config}, %TextChanged{} = event) do
    analyzer_config
    |> Enum.map(&Session.analyzer_for_key(&1))
    |> Enum.each(fn analyzer -> analyzer.analyze(event) end)
  end

  defp setup_subscriptions(%Session{active_analyzers: analyzer_config, id: session_id}) do
    analyzer_config
    |> Enum.map(&Session.analyzer_for_key(&1))
    |> Enum.each(fn analyzer ->
      AnalyzerSubscriber.setup(analyzer, session_id)
    end)
  end
end
