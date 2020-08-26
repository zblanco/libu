defmodule Libu.Analysis.Methods.Text do
  @moduledoc """
  Standard sets of text analysis.

  ### Text Metrics we want to collect

  * Total word count
  * Count of a given word
  * # of characters
  * Tokenized text?
  """

  def sentences(text) do
    Essence.Chunker.sentences(text)
  end

  def tokenize(text) do
    Essence.Tokenizer.tokenize(text)
  end

  # TODO, return a map instead of tuple list
  def word_counts(text, variation \\ :eager)
  def word_counts(text, :eager) when is_binary(text) do
    text
    |> String.downcase
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.reduce(Map.new, fn(word, map) ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
  end

  def word_counts(text, :lazy) when is_binary(text) do
    {:ok, stream_text} = StringIO.open(text)

    stream_text
    |> IO.binstream(:line)
    |> Stream.flat_map(&String.split(&1, " "))
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, & &1 + 1)
    end)
    |> Enum.to_list()
  end

  def word_counts(text, :flow) when is_binary(text) do
    {:ok, stream_text} = StringIO.open(text)

    stream_text
    |> IO.binstream(:line)
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split(&1, " "))
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, & &1 + 1)
    end)
    |> Enum.to_list()
  end

  def count_of_words(text) when is_binary(text) do
    text
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.count()
  end
end
