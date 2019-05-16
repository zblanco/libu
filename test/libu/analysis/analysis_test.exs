defmodule Libu.AnalysisTest do
  use ExUnit.Case
  alias Libu.Analysis

  test "basic/stateless text analysis" do
    result = Analysis.analyze("A sentence of text does great good")
    assert is_map(result)
    assert %{
      overall_sentiment: _,
      sentiment_score_per_word: _,
      total_word_count: _,
      words_count: _,
    } = result
  end
end
