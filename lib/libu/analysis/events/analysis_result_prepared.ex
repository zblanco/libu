defmodule Libu.Analysis.Events.AnalysisResultsPrepared do
  @moduledoc """
  Signals Query model readiness to our front-end for a Reportable Analysis Result.

  Reacting to this event should consist of calling `Analysis.fetch_results/2` for the session_id and metric_name.
  """
  defstruct [
    :session_id,
    :metric_name,
  ]
  @type t()  :: %__MODULE__{
    session_id: String.t(),
    metric_name: String.t(),
  }
end
