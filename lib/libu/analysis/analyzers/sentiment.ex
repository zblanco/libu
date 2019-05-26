defmodule Libu.Analysis.Sentiment do
  @moduledoc """
  Uses Veritaserum for basic sentiment analysis.

  TODO:
  * just produce overall sentiment, move Utility functions out.
  *

  """
  @behaviour Libu.Analysis.Analyzer

  def analyze(text) when is_binary(text) do
    {:ok, Veritaserum.analyze(text)}
  end
end
