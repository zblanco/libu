defmodule Libu.Analysis.Analyzer do
  @moduledoc """
  TODO:
  * Consider implementing something like Phoenix.HTML.Safe
  """
  @type msg :: String.t()
  @type analysis ::
    String.t()
    | map()
    | integer()

  @callback analyze(msg()) :: {:ok, analysis()} | {:error, any}
end
