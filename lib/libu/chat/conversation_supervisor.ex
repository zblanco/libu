defmodule Libu.Chat.ConversationSupervisor do
  @moduledoc """

  """
  use DynamicSupervisor
  alias Libu.Chat.{Conversation, ConversationProcess}

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_conversation(%Conversation{} = conv) do
    child_spec = {ConversationProcess, conv}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_conversation(via) do
    via
    |> GenServer.whereis()
    |> (fn pid ->
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end).()
  end
end
