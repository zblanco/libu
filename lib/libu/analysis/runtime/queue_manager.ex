defmodule Libu.Analysis.QueueManager do
  @moduledoc """
  Utilizes EtsQueue for use with Jobs and Broadway.

  Behaviour we need to implement:

  * enqueue one or more jobs to the queue
  * remove jobs based on session ends (key from session ids?)
    (we'll need to monitor sessions and handle exits to remove unecessary jobs)
  * remove jobs that are currently processing (place them somewhere else until ack'd for restart?)
  * implement ack behaviour of Broadway to remove references to active jobs

  Todo:

  * Shuffle taken not_started jobs into active_jobs
  * Ack from active_jobs
  """
  use GenServer

  alias Libu.Analysis.{Job, EtsQueue, JobProducer}

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(_) do
    state = setup_queues()
    {:ok, state}
  end

  def enqueue(%Job{} = job) do
    with %{not_started: not_started} <- fetch_queues(),
         :ok <- EtsQueue.put(not_started, job)
    do
      # JobProducer.notify_of_job_enqueuing()
      Libu.Messaging.publish(:job_enqueued, Libu.Analysis.topic() <> ":jobs")
    end
  end

  def fetch_jobs(amount) when is_integer(amount) do
    with %{not_started: not_started} <- fetch_queues(),
         {:ok, _jobs} = return <- EtsQueue.take(not_started, amount) do
      return
    else
      _ -> {:error, "Error occurred accessing queues"}
    end
  end

  def show_all_jobs() do
    with %{not_started: not_started} <- fetch_queues() do
      {:ok, EtsQueue.show_all(not_started)}
    else
      _ -> {:error, "Error reading queues"}
    end
  end

  def terminate(_reason, %{} = queues) do
    Enum.each(queues, fn {_name, queue} ->
      EtsQueue.terminate(queue)
    end)
    :ets.delete(:queues)
  end

  defp fetch_queues() do
    [{:queues, queues}] = :ets.lookup(:queues, :queues)
    queues
  end

  defp setup_queues do
    queue_state = %{
      not_started: EtsQueue.new(),
      active: EtsQueue.new()
    }
    _tid = :ets.new(:queues, [:named_table, :set, :protected])
    :ets.insert(:queues, {:queues, queue_state})
    queue_state
  end
end
