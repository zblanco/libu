defmodule Libu.Analysis.Session do
  @moduledoc """
  Represents the state of a 1:1 LiveView session.
  """
  alias Libu.Analysis.AnalysisResult

  defstruct id: nil,
            text: "",
            edit_count: 0,
            analysis: %AnalysisResult{
              session_id: nil,
              overall_sentiment: 0,
              sentiment_score_per_word: 0,
              total_word_count: 0,
              words_count: 0,
            }

  def new(session_id) when is_binary(session_id) do
    struct(__MODULE__, [id: session_id])
  end

  def start, do: UUID.uuid4()
end
