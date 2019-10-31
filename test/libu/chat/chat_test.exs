defmodule Libu.ChatTest do
  use ExUnit.Case
  alias Libu.Chat
  alias Libu.Chat.Message

  # test cursor based querying of conversations
  # test conversation lifecycle
  # test ending a conversation
  # test ttl of a message
  # test queries
  # test caching

  describe "conversations:: " do

    test "successfully initiating a conversation returns a conversation id" do
      {:ok, convo_id} = start_test_conversation()

      assert convo_id != nil
      assert is_binary(convo_id)
    end

    test "adding a message to a conversation appends an event to the conversation log" do
      {:ok, convo_id} = start_test_conversation()

      assert :ok == add_message_to_test_conversation(convo_id)
    end

    test "initiating a conversation with the :form options returns a changeset" do
      form_validation_changeset = Chat.initiate_conversation(%{}, form: true)
      assert match?(%Ecto.Changeset{}, form_validation_changeset)
    end

    test "adding to a conversation with the form option returns a changeset" do
      form_validation_changeset = Chat.add_to_conversation(%{}, form: true)
      assert match?(%Ecto.Changeset{}, form_validation_changeset)
    end

    test "conversation started events are published to pub sub upon successful initiation" do
      Chat.subscribe()

      start_test_conversation()

      assert_receive %Chat.Events.ConversationStarted{}

      Libu.Messaging.unsubscribe(Chat.topic())
    end

    test "message added to conversation events are published to pub sub after adding" do
      {:ok, convo_id} = start_test_conversation()

      Chat.subscribe(convo_id)

      :ok = add_message_to_test_conversation(convo_id)

      assert_receive %Chat.Events.MessageAddedToConversation{}

      Libu.Messaging.unsubscribe(Chat.topic())
    end
  end

  describe "query layer:: " do

    test "initiating a conversation starts a projector" do
      {:ok, convo_id} = start_test_conversation()

      assert Chat.ConversationProjectorSupervisor.is_conversation_projecting?(convo_id)
    end

    test "adding a message to a conversation without a running projector restarts the projector" do
      {:ok, convo_id} = start_test_conversation()
      :ok = Chat.ConversationProjectorSupervisor.stop_conversation_projector(convo_id)

      :ok = add_message_to_test_conversation(convo_id)

      assert Chat.ConversationProjectorSupervisor.is_conversation_projecting?(convo_id)
    end

    test "fetching messages of a conversation activates a projector cache" do
      {:ok, convo_id} = start_test_conversation()
      :ok = Chat.ConversationProjectorSupervisor.stop_conversation_projector(convo_id)

      {:ok, _messages} = Chat.fetch_messages(convo_id, 0, 10)

      assert Chat.ConversationProjectorSupervisor.is_conversation_projecting?(convo_id)
    end

    test "we can fetch an individual message by number" do
      {:ok, convo_id} = setup_full_conversation()

      assert match?(%Message{
          conversation_id: convo_id,
          message_number: 1,
          body: "Fezzik, are there rocks ahead?",
          publisher_name: "Inigo Montoya",
        },
        Chat.fetch_message(convo_id, 1)
      )
    end

    test "we can fetch many messages by number returned as a map by message number" do
      {:ok, convo_id} = setup_full_conversation()
      {:ok, messages} = Chat.fetch_messages(convo_id, [1, 3, 5])

      assert match?(%{
          1 => %Message{message_number: 1, body: "Fezzik, are there rocks ahead?"},
          3 => %Message{message_number: 3, body: "No more rhymes now, I mean it!"},
          5 => %Message{message_number: 5, body: "DYEEAAHHHHHH!"},
        },
        messages
      )
    end

    test "we can fetch many messages by start and end indexes" do
      {:ok, convo_id} = setup_full_conversation()
      {:ok, messages} = Chat.fetch_messages(convo_id, 1, 3)

      assert length(messages) == 3
      assert List.first(messages).message_number == 1
    end

    test "a message fetched resets the time to live" do
      # setup convo
      # assert that a message isn't yet cached
      # fetch message
      # assert that the message is now cached with a ttl
      {:ok, convo_id} = setup_full_conversation()
      # check the ttl of a message
      # fetch the message,
      assert false
    end

    test "when all projected messages expire, the projector shuts down" do
      # setup convo
      # fetch a message and assert the projector is alive
      # modify ttls to a short period
      # verify with supervisor that the projector isn't active anymore
      assert false
    end

    test "trying to fetch messages of an invalid/never-initiated conversation returns an error" do
      assert Chat.fetch_messages("some-bogus-convo-id", 1, 5) == {:error, :invalid_conversation}

      # assert that there isn't a projector active
    end

    test "freshly active conversations are projected automatically" do
      # setup convo
      # check supervisor that a projector is already active for that convo
      # check active conversation state that the conversation is there
      assert false
    end

    test "latest messages are updated in the active conversation" do
      # setup a convo
      # fetch active conversations
      # get an active conversation
      # add a new message
      # verify `latest_message` is updated with the new one
      assert false
    end

    test "fetching a conversation gets us metadata about a conversation" do
      # setup a convo
      # fetch a convo
      # verify conversation length/message-count
      # verify start time
      # verify latest activity
      assert false
    end
  end

  defp start_test_conversation() do
    Chat.initiate_conversation(%{
      title: "Rhymes aren't crimes!",
      message: "Fezzik, are there rocks ahead?",
      initiator_id: 1,
      initiator_name: "Inigo Montoya",
    })
  end

  defp add_message_to_test_conversation(convo_id) do
    Chat.add_to_conversation(%{
      conversation_id: convo_id,
      message: "If there are, we all be dead.",
      publisher_id: 2,
      publisher_name: "Fezzik"
    })
  end

  defp setup_full_conversation() do
    {:ok, convo_id} = Chat.initiate_conversation(%{
      title: "Rhymes aren't crimes!",
      message: "Fezzik, are there rocks ahead?",
      initiator_id: 1,
      initiator_name: "Inigo Montoya",
    })

    :ok = Chat.add_to_conversation(%{
      conversation_id: convo_id,
      message: "If there are, we all be dead.",
      publisher_id: 2,
      publisher_name: "Fezzik"
    })

    :ok = Chat.add_to_conversation(%{
      conversation_id: convo_id,
      message: "No more rhymes now, I mean it!",
      publisher_id: 3,
      publisher_name: "Vizzini"
    })

    :ok = Chat.add_to_conversation(%{
      conversation_id: convo_id,
      message: "Anybody want a peanut?",
      publisher_id: 2,
      publisher_name: "Fezzik"
    })

    :ok = Chat.add_to_conversation(%{
      conversation_id: convo_id,
      message: "DYEEAAHHHHHH!",
      publisher_id: 3,
      publisher_name: "Vizzini"
    })

    {:ok, convo_id}
  end
end
