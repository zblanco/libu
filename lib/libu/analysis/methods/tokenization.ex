defmodule Libu.Analysis.Tokenization do
  @moduledoc """
  Utilities to [Tokenize](https://nlp.stanford.edu/IR-book/html/htmledition/tokenization-1.html) text into more consistent processable shapes.

  Both an Analyzer implementation and an at-will module for use by other Analyzers.
  """
  def tokenize(text) do
    Essence.Tokenizer.tokenize(text)
  end
end
