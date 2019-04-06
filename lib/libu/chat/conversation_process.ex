defmodule Libu.Chat.ConversationProcess do
  @moduledoc """
  A Process which represents a tree of related messages.
  """
  alias Libu.Chat.{
    Conversation,
    Message,
  }

  use GenServer, restart: :transient

  @default_timeout :timer.minutes(60)

  def start_link(%Conversation{} = conv) do
    GenServer.start_link(__MODULE__, conv, name: via(conv.id))
  end
  def start_link(_), do: :invalid_conversation

  def via(id) when is_binary(id), do: {:via, Registry, {Registry.Conversations, id}}
  def via(_id), do: :non_binary_id

  def init(conversation), do: {:ok, conversation, {:continue, :init}}

  def handle_continue(:init, conversation) do
    {:noreply, conversation}
  end

  defp call(via, action) do
    pid =
      case GenServer.whereis(via) do
        nil ->
          {:ok, pid} = DesignSupervisor.start_design_process(via)
          pid
        pid -> pid
      end

    GenServer.call(pid, action)
  end

  def initiate_conversation() do

  end
end
