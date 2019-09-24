defmodule Libu.Metrics.PubSub do
  @moduledoc """
  Specifies the contract a Pub Sub must implement for use with Metrics.
  """
  @callback publish(message :: message(), topic :: topic()) ::
    :ok | {:error, term()}

  @callback subscribe(topic :: topic()) ::
    :ok | {:error, term()}

  @type topic() :: binary

  @type message() :: term()

  def subscribe(pub_sub, topic),
    do: pub_sub.subscribe(topic)

  def publish(pub_sub, message, topic),
    do: pub_sub.broadcast(topic, message)
end
