defmodule Libu.Messaging do

  def pub_sub, do: Libu.PubSub

  def subscribe(topic),
    do: Phoenix.PubSub.subscribe(pub_sub(), topic)

  def publish(message, topic),
    do: Phoenix.PubSub.broadcast(pub_sub(), topic, message)

end
