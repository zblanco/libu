defmodule Libu.Analysis.Analyzer do
  @moduledoc """
  Should this instead define a set of functions or modules that can be run via flow as a computation?
  """
  alias Libu.Analysis.Session
  @type msg :: String.t() | Session.t()
  @type analysis ::
    String.t()
    | map()
    | integer()

  @callback analyze(msg()) :: {:ok, analysis()} | {:error, any}


end
