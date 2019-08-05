defmodule Libu.Analysis.Analyzer do
  @moduledoc """
  """
  alias Libu.Analysis.Session
  @type msg :: String.t() | Session.t()
  @type analysis ::
    String.t()
    | map()
    | integer()

  @callback analyze(msg()) :: {:ok, analysis()} | {:error, any}
end
