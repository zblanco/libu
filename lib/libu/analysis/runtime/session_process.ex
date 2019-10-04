defmodule Libu.Analysis.SessionProcess do
  @moduledoc """
  Holds on to the Analysis Session State that dictates which jobs are run with new versions of text and how to collect results.

  Dynamically Supervised to maintain a 1:1 relationship with a LiveView.

  Basic Lifecycle:

  * @first live view mount: start an analysis session under a Dynamic Supervisor with the initial state.
    * We build up a set of Jobs and Collector processes to run and collect metrics with
  * @liveview de-mount: kill the analysis session (temporary)
    * we may eventually keep around on a timeout with some integration with the `Identity` context.
  * @text change: Inject jobs with new text and enqueue for processing.
  * @metric_toggle off: For a given metric we terminate collectors and the job for that metric.
  * @metric_toggle on: Start the collector then build and add the job to the pipeline. Dispatch just that job for the current text.
  """
  use GenServer
  alias Libu.Analysis.{
    Session,
    Events.TextChanged,
    Job,
    CollectorSupervisor,
    QueueManager,
    Messaging,
  }

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, {__MODULE__, session_id}}}
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
    {:ok, _pid} = CollectorSupervisor.start_link(session.id)
    {:ok, session, {:continue, :init}}
  end

  def handle_continue(:init, session) do
    setup_metrics(session)
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
    Session.publish_about(event, session.id)
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

  defp dispatch_jobs(%Session{} = session, %TextChanged{} = event) do
    session.job_pipeline
    |> Enum.map(fn {_name, %Job{} = job} ->
      %Job{job | input: event}
    end)
    |> Enum.map(&Job.evaluate_runnability(&1))
    |> Enum.filter(fn %Job{runnable?: runnability} -> runnability end)
    |> Enum.each(&QueueManager.enqueue(&1))
  end

  defp setup_metrics(%Session{collectors: collectors, id: session_id}) do
    Enum.each(collectors, fn {_name, module} ->
      CollectorSupervisor.start_collector(module, session_id)
    end)
  end
end
