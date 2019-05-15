defmodule Libu.Analysis.BasicSentiment do
  @moduledoc """
  Uses Veritaserum for basic sentiment analysis.
  """
  @behaviour Libu.Analysis.Analyzer

  def analyze(text) when is_binary(text) do
    {:ok, Veritaserum.analyze(text)}
  end
end
