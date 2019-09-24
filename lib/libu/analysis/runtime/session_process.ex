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

  Basic Lifecycle:

  * @first live view mount: start an analysis session under a Dynamic Supervisor with the initial state.
    * Build jobs and metrics
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
    Job,
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

  def end_session(session_id) do
    GenServer.stop(via(session_id))
  end

  def init(session) do
    # {:ok, _pid} = SessionWorkSupervisor.start_link(session.id)
    # Create the Session ETS table?
    {:ok, session, {:continue, :init}}
  end

  def handle_continue(:init, session) do
    # tid = :ets.new()
    # setup_metrics(session)
    {:noreply, session}
  end

  def notify_text_changed(_session_id, text) when is_nil(text), do: {:error, :nothing_to_analyze}
  def notify_text_changed(session_id, text) when is_binary(text) do
    GenServer.call(via(session_id), {:handle_text_change, text})
  end

  def toggle_metric(session_id, metric_name) when is_atom(metric_name) do
    GenServer.call(via(session_id), {:toggle_metric, metric_name})
  end

  def handle_call({:handle_text_change, text}, _from, session) do
    session =
      session
      |> Session.set_text(text)
      |> Session.increment_changes()

    event = TextChanged.new(session)
    Libu.Messaging.publish(event, Libu.Analysis.topic() <> ":#{session.id}")
    dispatch_jobs(session, event)

    {:reply, :ok, session}
  end

  # def handle_call({:toggle_metric, metric_name}, %Session{} = session) do
  #   # Terminate the subscriber processes toggled off
  #   session =
  #     if Session.available_metric?(metric_name) do
  #       Session.toggle_metric(session, metric_name)
  #     end

  #     # pause_if_deactivated(session)
  #   {:reply, :ok, session}
  # end

  def dispatch_jobs(%Session{} = session, %TextChanged{} = event) do
    session.job_pipeline
    |> Enum.map(fn {_name, %Job{} = job} ->
      %Job{job | input: event}
    end)
    |> Enum.map(&Job.evaluate_runnability(&1))
    |> Enum.filter(fn %Job{runnable?: runnability} -> runnability end)
    |> IO.inspect(label: "jobs to enqueue being dispatched...")
    |> Enum.each(&Libu.Analysis.Queue.enqueue(&1))
  end

  # defp setup_metrics(%Session{metrics: metrics, id: session_id}) do
  #  # start collector processes under the Session metrics Supervisor?
  # end
end
