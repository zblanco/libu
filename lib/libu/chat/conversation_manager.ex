defmodule Libu.Chat.ConversationManager do
  @moduledoc """
  Local-Node-Only-SGP responsible for maintaining an ETS table of active conversations.
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    :ets.new(:active_conversations, [:set, :protected, :named_table])
    # TODO: handle_continue stream in active conversations
    {:ok, %{}}
  end

  def handle_call({:add_conversation, conversation_id, initial_message}, _from, state) do
    with true <- :ets.insert_new(:active_conversations, {conversation_id, initial_message}) do
      {:reply, :ok, state}
    else
      _ -> {:reply, :error, state}
    end
  end


end
