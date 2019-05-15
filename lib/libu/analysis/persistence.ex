defmodule Libu.Analysis.Persistence do
  alias Libu.Analysis.AnalysisResult

  def create(%AnalysisResult{session_id: session_id} = result) do
    case :ets.insert_new(:analysis_results, {session_id, result}) do
      true  -> {:ok, result}
      false -> {:error, :duplicate_item}
    end
  end
  def create(_), do: :invalid_result

  def update(%AnalysisResult{} = result) do
    true = :ets.insert(:analysis_results, {result.session_id, result})
    {:ok, result}
  end
  def update(_), do: :invalid_result
end
