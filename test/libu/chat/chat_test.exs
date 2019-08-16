defmodule Libu.ChatTest do
  use ExUnit.Case
  alias Libu.Chat
  alias Libu.Chat.{Message, Conversation}

  # test cursor based querying of conversations
  # test conversation lifecycle
  # test ending a conversation
  # test ttl of a message

  describe "conversation initiation" do

    @tag :integration
    test "we should an :ok from initiating a conversation" do
      assert false
    end
  end

  describe "conversation stream querying" do

    test ""
  end
end
