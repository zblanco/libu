defmodule Libu.Analysis.Utilities do

  def word_count(text) do
    text
    |> String.downcase
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.reduce(Map.new, fn(word, map) ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
  end

  def number_of_words(text) do
    text
    |> String.split(~R/[^[:alnum:]\-]/u, trim: true)
    |> Enum.count()
  end
end
