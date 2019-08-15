defmodule Libu.Analysis.Collectors.Aggregator do
  @moduledoc """
  A process that aggregates a set of analysis results.

  Can be configured within a window of time.

  1. Spawn under the Collection Supervisor with a Metric to collect and the way to collect it
  2.
  """
  use GenServer

  # def init(%Metric{} = metric) do

  # end

end
