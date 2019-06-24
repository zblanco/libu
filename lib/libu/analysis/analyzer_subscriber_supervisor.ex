defmodule Libu.Analysis.AnalyzerSubscriberSupervisor do
  @moduledoc """
  Supervises Analyzer Subscribers for a given analysis session

  Started with a new Analysis session.
  """
  use DynamicSupervisor

  def start_link([session_id: session_id, initial_analyzers: initial_analyzers]) do
    DynamicSupervisor.start_link(__MODULE__, session_id)
  end

  # def init(initial_subscribers)
end
