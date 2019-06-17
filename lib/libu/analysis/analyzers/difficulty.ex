defmodule Libu.Analysis.Readability do
  @moduledoc """

  """
  alias Libu.Analysis.Tokenization

  def overall_difficulty(text) when is_binary(text) do
    text
    |> Essence.Document.from_text()
    |> Essence.Readability.dale_chall()
  end
end
