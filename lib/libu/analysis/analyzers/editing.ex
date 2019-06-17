defmodule Libu.Analysis.Editing do
  @moduledoc """
  Used to build editing state such as how long the editing session has lasted, how many edits have taken place, etc.

  An aggregator process supervised under a Session that builds a sliding window of state for the editing of some text.

  Consumed AnalysisResultProduced events to calculate various metrics about text editing.
  """
end
