defmodule Libu.Analysis.Analyzer do
  @moduledoc """
  A Text Analyzer must conform to this contract.
  """
  @type msg :: String.t()
  @type analysis ::
    String.t()
    | map()
    | integer()

  @callback analyze(msg()) :: {:ok, analysis()} | {:error, any}
end
