defmodule Libu.Analysis do
  @moduledoc """
  Analyzes text on-demand with configurable strategies.

  We start a stateful session with the contents of the updated anytime the text changes.

  Upon a change we queue up a text analysis job and cancel all existing work per strategy if it's still running.

  Upon receiving a `:text_analyzed` event the parent session can update it's set of results per strategy.
  """
  alias Libu.Analysis.{
    SessionProcess,
    Session,
    Query,
  }

  @doc """
  Used on mount of a LiveView.

  Starts a stateful session that maintains the set of analyzers and the text to analyze.
  """
  def start_session() do
    with session_id <- Session.start(),
         {:ok, _}   <- SessionProcess.start(session_id) do
      session_id
    end
  end

  def handle_text_change(session_id, text) do
    with {:ok, session} <- SessionProcess.analyze(session_id, text) do
      session
    else
      _ -> {:error, "Error analyzing text"}
    end
  end

  def fetch_analysis_results(session_id), do: Query.get(session_id)

  def setup_persistence(), do: :ets.new(:analysis_results, [:public, :named_table])
end
