defmodule Libu.AnalysisTest do
  use ExUnit.Case
  alias Libu.Analysis


  describe "text analysis: " do
    test "basic analysis returns a map of analytics data for text" do
      {:ok, rating} = Analysis.BasicSentiment.analyze("Some text input")
      assert is_map(rating)
      assert %{
        total_score: _,
        score_per_word: ,
        word_count: ,
        registered_edits: ,
      }
    end
  end
end
