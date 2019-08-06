defmodule Libu.Messaging do
  @moduledoc """
  Wrapper/Facade around pub sub capabilities so our Context modules don't need to know about Phoenix Pub Sub.
  """
  def pub_sub, do: Libu.PubSub

  def subscribe(topic),
    do: Phoenix.PubSub.subscribe(pub_sub(), topic)

  def publish(message, topic),
    do: Phoenix.PubSub.broadcast(pub_sub(), topic, message)

end
