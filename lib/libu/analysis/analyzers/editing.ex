defmodule Libu.Analysis.Editing do
  @moduledoc """
  Used to build editing state such as how long the editing session has lasted, how many edits have taken place, etc.

  An aggregator process supervised under a Session that builds a sliding window of state for the editing of some text.

  Consumed AnalysisResultProduced events to calculate various metrics about text editing.

  ## Metrics to track:

  * # of Changes / Current Text Version
  * Frequency of changes over time
  * Words Per Minute
  * Editing Session Length
  """

  # def analyze(text) when is_binary(text) do
  #   with total_word_count  <- word_counts(text, :eager),
  #        words_count       <- count_of_words(text)
  #   do
  #     {:ok, %{
  #       wpm: ,
  #       words_count:      words_count,
  #     }}
  #   end
  # end

  # def results_set, do: MapSet.new([
  #   :wpm,
  #   :changes,
  #   :duration,
  # ])
end
