defmodule Libu.ChatTest do
  use ExUnit.Case
  alias Libu.Chat
  alias Libu.Chat.{Message, Conversation}

  describe "core chat: " do

    test "a conversation can be started with a message" do
      {:ok, msg} = Message.new(%{publisher_id: "doops", body: "liveview is pretty neat"})
      conv = Conversation.start(msg)

      assert %Conversation{} = conv
    end

    test "we can add more messages to a conversation" do
      {:ok, msg} = Message.new(%{
        publisher_id: "doops",
        body: "liveview is pretty neat"
      })

      conv = Conversation.start(msg)

      {:ok, other_msg} = Message.new(%{
        parent_id: conv.id,
        publisher_id: "doops",
        body: "phoenix is cool too"
      })

      conv = Conversation.add_to(conv, other_msg)
      # Best way to assert an item was added to the list?
    end
  end


end
