defmodule Libu.Analysis.Events.AnalysisResultProduced do
  @moduledoc """
  The result produced by an Analyzer once a job is complete.

  This just contains a result so dependent Analysis Strategies can subscribe and utilize results for their own calculations.
  """
  defstruct [
    :session_id,
    :text_version,
    :produced_on,
    :metric_name,
    :result,
  ]
  @type t()  :: %__MODULE__{
    session_id: String.t(),
    text_version: integer(),
    produced_on: %DateTime{},
    metric_name: String.t(),
    result: any(),
  }

  def new(params) do
    struct!(__MODULE__, params)
  end
end
