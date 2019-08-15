defmodule Libu.Collectors.SlidingWindow do
  use GenServer

  def start_link(identifier, topic, duration_limit \\ 3600) do
    {:ok, _pid} = GenServer.start_link(
      __MODULE__,
      [identifier: identifier, topic: topic, duration_limit: duration_limit],
      name: via(identifier)
    )
  end

  def via(identifier) do
    {:via, Registry, {Libu.Analysis.CollectorRegistry, identifier}}
  end

  def init()
end
