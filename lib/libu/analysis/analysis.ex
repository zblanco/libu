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

  def analyze(text) when is_nil(text), do: {:error, :nothing_to_analyze}
  def analyze(text) when is_binary(text) do
    with sentiment_score  <- Veritaserum.analyze(text),
         total_word_count <- number_of_words(text),
         word_count       <- word_count(text)
    do
      %{
        overall_sentiment: sentiment_score,
        sentiment_score_per_word: sentiment_score / total_word_count,
        total_word_count: total_word_count,
        words_count: word_count,
      }
    end
  end

  def word_count(text) do
    text
    |> String.downcase
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.reduce(Map.new, fn(word, map) ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
  end

  def number_of_words(text) do
    text
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.count()
  end
end
