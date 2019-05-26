defmodule Libu.Analysis.Events.AnalysisResultProduced do
  @moduledoc """
  The result produced by an Analyzer once a job is complete.
  """
  defstruct [
    :session_id,
    :text_version,
    :produced_on,
    :analyzer,
    :result,
  ]
end
