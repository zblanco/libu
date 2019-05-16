defmodule Libu.Analysis.SimpleText do
  @moduledoc """
  Uses Veritaserum for basic sentiment analysis.
  """
  @behaviour Libu.Analysis.Analyzer

  def analyze(text) when is_binary(text) do
    with total_word_count  <- Utilities.number_of_words(text),
         words_count       <- Utilities.word_count(text),
         overall_sentiment <- Veritaserum.analyze(text)
    do
      {:ok, %{
        overall_sentiment:        overall_sentiment,
        sentiment_score_per_word: overall_sentiment / total_word_count,
        total_word_count:         total_word_count,
        words_count:              words_count,
      }}
    end

  end
end
