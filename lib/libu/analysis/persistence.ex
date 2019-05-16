defmodule Libu.Analysis.Persistence do
  alias Libu.Analysis.Session

  def create(%Session{session_id: session_id} = result) do
    case :ets.insert_new(:analysis_sessions, {session_id, result}) do
      true  -> {:ok, result}
      false -> {:error, :duplicate_item}
    end
  end
  def create(_), do: :invalid_result

  def update(%Session{} = result) do
    true = :ets.insert(:analysis_results, {result.session_id, result})
    {:ok, result}
  end
  def update(_), do: :invalid_result

  def setup, do: :ets.new(:analysis_results, [:public, :named_table])
end
