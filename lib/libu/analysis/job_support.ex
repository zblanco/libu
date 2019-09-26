defmodule Libu.Analysis.JobSupport do
  @moduledoc """
  Test helpers for Jobs.
  """
  alias Libu.Analysis.Job

  def squareaplier(num), do: {:ok, num * num}

  defmodule TestQueue do
    @behaviour Job.Queue

    def enqueue(%{} = _jobs), do: :ok
    def enqueue(_invalid_jobs), do: :error

    def ack(%Job{}), do: :ok
    def ack(_invalid_job), do: :error
  end
end
