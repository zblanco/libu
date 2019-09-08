defmodule Libu.Analysis.Metric do
  @moduledoc """
  Represents a collectable set of data.

  %Metric{
    name: "naive_sentiment",
    analyzer:
  }
  """
  defstruct [
    :name, # what we call the result
    :analyzer, # the anonymous function module/function pair to call to get a result
    :collector, # the kind of metric we're gathering
    :topic, # the messaging topic our analysis_result_produced/prepared events will be found on
  ]

  def new(params) do
    struct!(__MODULE__, params)
  end

  def subscribe_to(metric) do

  end
end
