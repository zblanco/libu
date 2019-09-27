defmodule Libu.Analysis.JobProducer do
  @moduledoc """
  Genstage producer for Analysis Jobs.

  Reads from the `Libu.Analysis.Queue` in response to demand to feed Broadway jobs to process.

  The Job Queue configured here returns a list of `%Job{}` structs so a Broadway pipeline should transform each `Job` into a `Message`.
  """
  use GenStage

  alias Libu.Analysis.{Job, Queue}

  @behaviour Broadway.Producer

  def init(_) do
    {:producer, %{demand: 0}}
  end

  def handle_demand(incoming_demand, %{demand: demand} = state) do
    handle_receive_messages(%{state | demand: demand + incoming_demand})
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
      case Queue.fetch_jobs(demand) do
        {:error, _error} -> []
        queued_jobs      -> queued_jobs
      end

    jobs
  end
end
