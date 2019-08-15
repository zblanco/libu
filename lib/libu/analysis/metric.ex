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
    :type, # the kind of metric we're gathering
    :topic, # the messaging topic our analysis_result_produced event will be found on
  ]
end
