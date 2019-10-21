defmodule Libu.Analysis.QueueManager do
  @moduledoc """
  Utilizes EtsQueue for use with Jobs and Broadway.
  """
  use GenServer

  alias Libu.Analysis.{Job, EtsQueue}

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(_opts) do
    state = setup()
    {:ok, state}
  end

  def enqueue(%Job{} = job) do
    with %{not_started: not_started} <- fetch_queues(),
         :ok <- EtsQueue.put(not_started, job)
    do
      Libu.Messaging.publish(:job_enqueued, Libu.Analysis.topic() <> ":jobs")
    end
  end

  def fetch_jobs(amount) when is_integer(amount) do
    with %{not_started: not_started} <- fetch_queues(),
         {:ok, jobs} = return <- EtsQueue.take(not_started, amount),
          :ok <- mark_jobs_as_running(jobs)
    do
      return
    else
      _ -> {:error, "Error occurred accessing queues"}
    end
  end

  def ack(%Job{run_id: run_id}) do
    :ets.delete(:running_jobs, run_id)
    :ok
  end

  def show_not_started_jobs() do
    with %{not_started: not_started} <- fetch_queues() do
      {:ok, EtsQueue.show_all(not_started)} # consider displaying both active and not_started jobs
    else
      _ -> {:error, "Error reading queues"}
    end
  end

  def show_running_jobs() do
    :ets.tab2list(:running_jobs)
  end

  def terminate(_reason, %{} = queues) do
    Enum.each(queues, fn {_name, queue} -> EtsQueue.terminate(queue) end)
    :ets.delete(:queues)
    :ets.delete(:running_jobs)
  end

  defp mark_jobs_as_running(jobs) do
    Enum.each(jobs, fn %Job{run_id: run_id} = job ->
      :ets.insert(:running_jobs, {run_id, job})
    end)
    :ok
  end

  defp fetch_queues() do
    [{:queues, queues}] = :ets.lookup(:queues, :queues)
    queues
  end

  defp setup do
    queue_state = %{not_started: EtsQueue.new()}
    _tid = :ets.new(:queues, [:named_table, :set, :protected])
    :ets.insert(:queues, {:queues, queue_state})

    _tid = :ets.new(:running_jobs, [:named_table, :set, :public])
    queue_state
  end
end
