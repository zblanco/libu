defmodule Libu.Chat.ConversationProcess do
  @moduledoc """
  A Process which represents a tree of related messages.
  """
  use GenServer, restart: :transient

  alias Libu.Chat
  alias Libu.Chat.{
    Conversation,
    ConversationSupervisor,
    Message,
    Query,
    Events.ConversationStarted,
    Events.MessagePublished,
  }

  @default_timeout :timer.minutes(60)

  def start_link(id) when is_binary(id) do
    GenServer.start_link(__MODULE__, id, name: via(id))
  end
  def start_link(_), do: :invalid_id

  def via(id) when is_binary(id), do: {:via, Registry, {Registry.Conversations, id}}
  def via(_id), do: :non_binary_id

  def init(conversation), do: {:ok, conversation, {:continue, :init}}

  def handle_continue(:init, id) do
    case Query.conversation(id) do
      {:ok, conversation} -> {:noreply, conversation}
      {:error, _} -> {:noreply, }
    end

  end

  defp call(via, action) do
    pid =
      case GenServer.whereis(via) do
        nil ->
          {:ok, pid} = ConversationSupervisor.start_conversation(via)
          pid
        pid -> pid
      end

    GenServer.call(pid, action)
  end

  def add_to_conversation(via, %Message{} = msg), do: call(via, {:add_to_conversation, msg})

  def handle_call({:intiate_conversation, msg}, _from, _conv) do
    conversation = Conversation.start(msg)

    # conversation
    # |> ConversationStarted.new()
    # |> Chat.notify_subscribers()

    {:reply, :ok, conversation}
  end

  def handle_call({:add_to_conversation, msg}, _from, %Conversation{} = conv) do
    # Publish messages to pub sub

    # Check with Conversation rules
    # Persist updated state
    # Return Updated State
    {:reply, :ok, Conversation.add_to(conv, msg), @default_timeout}
  end
end
