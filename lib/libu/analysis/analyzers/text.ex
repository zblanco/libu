defmodule Libu.Analysis.Text do
  @moduledoc """
  Uses Veritaserum for basic sentiment analysis.

  TODO:
  * just produce overall sentiment, move Utility functions out.
  *

  """
  @behaviour Libu.Analysis.Analyzer

  def analyze(text) when is_binary(text) do
    with total_word_count  <- total_word_count(text, :eager),
         words_count       <- word_count(text),
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

  def total_word_count(text, :eager) when is_binary(text) do
    text
    |> String.downcase
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.reduce(Map.new, fn(word, map) ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
  end

  def total_word_count(text, :lazy) when is_binary(text) do
    text
    |> Stream.flat_map(&String.split(&1, " "))
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, & &1 + 1)
    end)
    |> Enum.to_list()
  end

  def total_word_count(text, :flow) when is_binary(text) do
    text
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split(&1, " "))
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, & &1 + 1)
    end)
    |> Enum.to_list()
  end

  def number_of_words(text) when is_binary(text) do
    text
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.count()
  end
end
