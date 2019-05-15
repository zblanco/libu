defmodule Libu.Analysis.AnalysisResult do
  defstruct [
    :session_id,
    :overall_sentiment,
    :sentiment_score_per_word,
    :total_word_count,
    :words_count,
  ]
end
