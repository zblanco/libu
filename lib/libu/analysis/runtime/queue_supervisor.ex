defmodule Libu.Analysis.QueueSupervisor do
  @moduledoc """
  Rest_for_one supervision of the Queue processes.
  """
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Libu.Analysis.QueueManager, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
