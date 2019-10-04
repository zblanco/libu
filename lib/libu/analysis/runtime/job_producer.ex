defmodule Libu.Analysis.JobProducer do
  @moduledoc """
  Genstage producer for Analysis Jobs.

  Reads from the `Libu.Analysis.Queue` in response to demand to feed Broadway jobs to process.

  The Job Queue configured here returns a list of `%Job{}` structs so a Broadway pipeline should transform each `Job` into a `Message`.

  TODO:

  * Implement Broadway Ack behaviours
    * Consider creating two ETS queues:
      * One for fresh jobs
      * One for working jobs (acknowledge from here to remove)
        - Retries & removals?
    * Handle messages from session ends to cancel running jobs and remove from queues
  """
  use GenStage

  alias Libu.Analysis.{Job, QueueManager}
  alias Libu.Messaging
  alias Broadway.Message

  @behaviour Broadway.Producer

  @impl true
  def init(_) do
    Messaging.subscribe(Libu.Analysis.topic() <> ":jobs")
    {:producer, %{demand: 0}}
  end

  def notify_of_job_enqueuing() do
    GenStage.cast(__MODULE__, :job_enqueued)
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
  def handle_demand(incoming_demand, %{demand: demand} = state) do
    handle_receive_messages(%{state | demand: demand + incoming_demand})
  end

  defp handle_receive_messages(%{demand: demand} = state) when demand > 0 do
    IO.puts "producer fetching from the queue... "
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
      acknowledger: nil,
    }
  end
end
