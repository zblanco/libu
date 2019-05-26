defmodule Libu.Analysis.Analyzer do
  @moduledoc """
  TODO:
  * Consider this might be the wrong boundary for the contract.
  * A text analysis function should be stateless and composable.
  * The real contract should be around our workers the produce results.
  """
  @type msg :: String.t()
  @type analysis ::
    String.t()
    | map()
    | integer()

  @callback analyze(msg()) :: {:ok, analysis()} | {:error, any}
end
