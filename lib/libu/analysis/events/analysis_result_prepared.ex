defmodule Libu.Analysis.Events.AnalysisResultsPrepared do
  @moduledoc """
  Signals Query model readiness to our front-end for a given Analysis Strategy.

  Reacting to this event should consist of calling `Analysis.fetch_analysis_results/2` for the session_id and analyzer.
  """
  defstruct [
    :session_id,
    :analyzer,
  ]
  @type t()  :: %__MODULE__{
    session_id: String.t(),
    analyzer: atom(),
  }
end
