defmodule Libu.Analysis do
  @moduledoc """
  Analyzes text on-demand with configurable strategies.

  We start a stateful session with the contents of the updated anytime the text changes.

  Upon a change we queue up a text analysis job and cancel all existing work per strategy if it's still running.

  Upon receiving a `:text_analyzed` event the parent session can update it's set of results per strategy.
  """

  # def analyze(text, opts \\ []) when is_binary(text) do
  #   # fetch all configured strategies from session
  # end

  @doc """
  Used on mount of a LiveView component.

  Starts a stateful session that maintains the set of analyzers to queue commands to.
  """
  # def start_analysis_session(intial_text, analyzers \\ [:naive_sentiment]) do
  #   # Use a dynamic supervisor to spawn an analysis session

  #   session = AnalysisManager.start_session(initial_text, analyzers)
  # end

  # def update_analyzers(session_id, analyzers) do

  # end

  def analyzer_options() do
    [
      %{name: "Naive Analysis"},
      %{name: "Google NLP"},
    ]
  end
end
