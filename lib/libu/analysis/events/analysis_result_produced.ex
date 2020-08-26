defmodule Libu.Analysis.Events.AnalysisResultProduced do
  @moduledoc """
  Published with the results of a completed analysis job.

  Meant to be consumed by some projector/collector process.
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
