defmodule Libu.Analysis.Events.AnalysisResultProduced do
  @moduledoc """
  The result produced by an Analyzer once a job is complete.

  This just contains a result so dependent Analysis Strategies can subscribe and utilize results for their own calculations.
  """
  defstruct [
    :session_id,
    :text_version,
    :produced_on,
    :analyzer, # Module
    :result, # How do we format the results for complex UI representation?
  ]
  @type t()  :: %__MODULE__{
    session_id: String.t(),
    text_version: integer(),
    produced_on: %DateTime{},
    analyzer: module() | function(),
    result: any(),
  }
end
