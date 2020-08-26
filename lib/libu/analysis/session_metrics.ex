defmodule Libu.Analysis.SessionMetrics do
  @moduledoc """
  Implementations of Analysis Metrics.
  """
  alias Libu.Analysis.{
    Events.TextChanged,
    Methods.Readability,
    Methods.Sentiment,
    Methods.Text,
  }

  def dale_chall_difficulty(%TextChanged{text: text}) do
    {:ok, Readability.dale_chall_difficulty(text)}
  end

  def basic_sentiment(%TextChanged{text: text}) do
    {:ok, Sentiment.basic_sentiment(text)}
  end

  def count_of_words(%TextChanged{text: text}) do
    {:ok, Text.count_of_words(text)}
  end

  def word_counts(%TextChanged{text: text}) do
    {:ok, Text.word_counts(text)}
  end

  def average_sentiment_per_word(%TextChanged{text: text}) do
    {:ok, Sentiment.average_sentiment_per_word(text)}
  end
end
