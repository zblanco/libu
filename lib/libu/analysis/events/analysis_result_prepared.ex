defmodule Libu.Analysis.Events.AnalysisResultsPrepared do
  @moduledoc """
  Used to
  """
  defstruct [
    :session_id,
    :analyzer,
  ]
  @type t()  :: %__MODULE__{
    session_id: String.t(),
    analyzer: module() | function(),
  }
end
