defmodule Libu.Metrics.MetricsPubSubAdapter do
  @behaviour Libu.Metrics.PubSub

  alias Libu.Messaging

  @impl true
  defdelegate publish(message, topic), to: Messaging

  @impl true
  defdelegate subscribe(topic), to: Messaging
end
