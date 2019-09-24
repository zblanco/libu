defmodule Libu.Analysis.JobProducer do
  @moduledoc """
  Genstage producer for Analysis Jobs.

  Reads from the `Libu.Analysis.Queue` in response to demand to feed Broadway jobs to process.
  """
  use GenStage

  alias Libu.Analysis.{Job, Queue}

  @behaviour Broadway.Producer

  def init(_) do
    {:producer, 0}
  end

  def handle_demand(demand, pending_demand) when demand > 0 do
    {_count, jobs} = fetch_jobs(demand) # how should we handle pending demand?
    IO.puts "handling demand"
    {:noreply, jobs, pending_demand}
  end

  defp fetch_jobs(demand) do
    jobs =
      case Queue.fetch_jobs(demand) do
        {:error, _error} -> []
        queued_jobs      -> queued_jobs
      end

    count = length(jobs)
    {count, jobs}
  end
end
