defmodule Libu.AnalysisTest do
  use ExUnit.Case
  alias Libu.Analysis

  @sample_text """
  True happiness is to enjoy the present, without anxious dependence upon the future,
  not to amuse ourselves with either hopes or fears but to rest satisfied with what we have, which is sufficient,
  for he that is so wants nothing. The greatest blessings of mankind are within us and within our reach.
  A wise man is content with his lot, whatever it may be, without wishing for what he has not.
  """

  describe "Text Analysis:  " do
    test "analyze/1" do
      assert false
    end

    test "word_counts/2" do
      assert false
    end

    test "count_of_words/1" do
      assert false
    end
  end

  # TODO:
    # Sentiment
    # Tokenization
    # Aggregations
end
