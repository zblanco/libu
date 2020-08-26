defmodule Libu.Analysis.Methods.Readability do
  @moduledoc """
  Metrics we want to collect:

  * Current reading difficulties
  * Reading difficulties over time
  """
  def dale_chall_difficulty(text) when is_binary(text) do
    text
    |> Essence.Document.from_text()
    |> Essence.Readability.dale_chall()
  end
end
