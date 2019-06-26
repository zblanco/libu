defmodule Libu.Analysis.Query do


  def fetch(session_id) when is_binary(session_id) do
    case :ets.lookup(:analysis_results, session_id) do
      [{_id, result}] -> {:ok, result}
      _               -> {:error, :no_analysis_results_found}
    end
  end
end
