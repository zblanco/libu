defmodule Libu.Analysis do
  @moduledoc """
  Analyzes text on-demand with configurable strategies.

  We start a stateful session with the contents of the updated anytime the text changes.

  Upon a change we queue up a text analysis job and cancel all existing work per strategy if it's still running.

  Upon receiving a `:text_analyzed` event the parent session can update it's set of results per strategy.
  """
  alias Libu.Analysis.{NaiveSentiment, SessionProcess, Session}

  def analyze(text) when is_binary(text) do
    with {:ok, analysis} <- NaiveSentiment.analyze(text) do
      analysis
    end
  end

  def analyze(session_id, text) do
    SessionProcess.analyze(session_id, text)
  end

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

  # def update_analyzers(session_id, analyzers) do

  # end
end
