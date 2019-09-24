defmodule Libu.Analysis.Methods.Sentiment do
  @moduledoc """
  Utilities and Analyzer Behaviour implementation for [Sentiment](https://web.stanford.edu/class/cs124/lec/sentiment.pdf) analysis.

  ### Metrics we want to gather about Sentiment:

  * Current basic sentiment
  * Basic sentiment over time
  * Average Sentiment score per word
  * Average Sentiment score per word over time
  """
  alias Libu.Analysis.Methods.Text


  def basic_sentiment(tokenized_text)
  when is_list(tokenized_text),
  do: Veritaserum.analyze(tokenized_text)

  def basic_sentiment(text),
    do: Veritaserum.analyze(text)

  def average_sentiment_per_word(text)
  when is_binary(text) do
    average_sentiment_per_word(
      basic_sentiment(text),
      Text.count_of_words(text)
    )
  end
  def average_sentiment_per_word(score, total_word_count)
  when is_integer(score)
  and is_integer(total_word_count) do
    score / total_word_count
  end
end
