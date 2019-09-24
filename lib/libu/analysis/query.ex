defmodule Libu.Analysis.Query do

  def available_metrics() do
    []
  end

  def fetch(session_id) when is_binary(session_id) do
    case :ets.lookup(:analysis_results, session_id) do
      [{_id, result}] -> {:ok, result}
      _               -> {:error, :no_analysis_results_found}
    end
  end

  def fetch(session_id, analyzer_key)
  when is_binary(session_id) and is_atom(analyzer_key) do
    # The query formats of some analysis strategies may be different.
    # Some analysis strategy results will want a windowed time-series set of events
    # Others will just want to store terms with key-values.
  end
end
