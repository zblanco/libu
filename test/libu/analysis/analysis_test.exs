defmodule Libu.AnalysisTest do
  use ExUnit.Case
  alias Libu.Analysis


  describe "text analysis: " do
    test "naive analysis returns an integer rating for text" do
      {:ok, rating} = Analysis.NaiveSentiment.analyze("Some text input")
      assert is_integer(rating)
    end
  end
end
