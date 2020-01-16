defmodule Libu.Analysis.JobProducer do
  @moduledoc """
  Genstage producer for Analysis Jobs.

  Reads from a Queue when demanded to feed Broadway jobs to run.

  The Job Queue configured here returns a list of `%Job{}` structs so a Broadway pipeline should transform each `Job` into a `Message`.

  TODO:

  * Handle messages from session ends to cancel running jobs and remove from queues
  """
  use GenStage

  alias Libu.Analysis.{Job, QueueManager}
  alias Broadway.{Message, Producer, Acknowledger}

  @behaviour Producer
  @behaviour Acknowledger

  @impl true
  def init(_) do
    {:producer, %{demand: 0}}
  end

  def notify_of_enqueuing() do
    producer_module = Broadway.producer_names(AnalysisBroadway) |> Enum.random()
    GenStage.cast(producer_module, :job_enqueued)
  end

  @impl true
  def handle_cast(:job_enqueued, state) do
    handle_receive_messages(state)
  end

  @impl true
  def handle_info(:job_enqueued, state) do
    handle_receive_messages(state) # todo replace with a cast to self
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, [], state}
  end

  @impl true
  def handle_demand(incoming_demand, %{demand: demand} = state) do
    handle_receive_messages(%{state | demand: demand + incoming_demand})
  end

  @impl Acknowledger
  def ack(_ack_ref, successful, _failed) do
    ack_jobs(successful)
    :ok
  end

  defp ack_jobs(successful_messages) do
    Enum.map(successful_messages, fn %Message{data: %Job{queue: queue} = job} ->
      queue.ack(job)
    end)
  end

  defp handle_receive_messages(%{demand: demand} = state) when demand > 0 do
    jobs = fetch_jobs(demand)
    new_demand = demand - length(jobs)
    {:noreply, jobs, %{state | demand: new_demand}}
  end

  defp handle_receive_messages(state) do
    {:noreply, [], state}
  end

  defp fetch_jobs(demand) do
    jobs =
      case QueueManager.fetch_jobs(demand) do
        {:error, _error}   -> []
        {:ok, queued_jobs} -> queued_jobs
      end

    jobs |> Enum.map(&to_message(&1))
  end

  defp to_message(%Job{} = job) do
    %Message{
      data: job,
      acknowledger: {__MODULE__, job.run_id, job.context}
    }
  end
end
