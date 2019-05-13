defmodule Libu.Analysis.GoogleNLP do
  @moduledoc """
  Uses Google's NLP API to do text analysis.
  """
  @behaviour Libu.Analysis.Analyzer

  def analyze(text) when is_binary(text) do
    {:ok, "Nothing yet."}
  end
end
