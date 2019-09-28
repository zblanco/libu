defmodule Libu.Analysis.Queue do
  @moduledoc """
  A Genserver wrapper around EtsQueue for use with Jobs and Broadway.

  Behaviour we need to implement:

  * enqueue one or more jobs to the queue
  * remove jobs based on session ends (key from session ids?)
    (we'll need to monitor sessions and handle exits to remove unecessary jobs)
  * remove jobs that are currently processing (place them somewhere else until ack'd for restart?)
  * implement ack behaviour of Broadway to remove references to active jobs
  """
  use GenServer

  alias Libu.Analysis.{Job, EtsQueue}
  alias Libu.Messaging

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(_) do
    queue = EtsQueue.new()
    {:ok, queue}
  end

  def enqueue(job) do
    GenServer.call(__MODULE__, {:enqueue, job})
  end

  def fetch_jobs(amount) when is_integer(amount) do
    GenServer.call(__MODULE__, {:fetch, amount})
  end

  def show_all_jobs(), do: GenServer.call(__MODULE__, :show_all)

  def handle_call({:fetch, amount}, _from, %EtsQueue{} = queue) do
    return =
      case EtsQueue.get(queue, amount) do
        {:error, _} = error -> error
        {:ok, jobs}         -> {:ok, jobs}
      end

    {:reply, return, queue}
  end

  def handle_call(:show_all, _from, %EtsQueue{} = queue) do
    queue_contents = EtsQueue.get_all(queue)
    {:reply, {:ok, queue_contents}, queue}
  end

  def handle_call({:enqueue, %Job{} = job}, _from, %EtsQueue{} = queue) do
    :ok = EtsQueue.put(queue, job)
    Messaging.publish(:job_enqueued, Libu.Analysis.topic() <> ":jobs")
    {:reply, :ok, queue}
  end

  def terminate(_reason, queue), do: EtsQueue.terminate(queue)
end
