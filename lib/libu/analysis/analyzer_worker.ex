defmodule Libu.Analysis.AnalyzerWorker do
  @moduledoc """
  Invokes a configured analyzer module to process some text.
  """
  alias Libu.Analysis.Events.TextChanged
  def analyze(%TextChanged{} = event, analyzer), do: analyzer.analyze(event)

end
