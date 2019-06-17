defmodule Libu.Chat.ConversationManager do
  @moduledoc """
  Maintains a registry of Conversations ocurring.

  Starts conversations when asked to.
  """
  use GenServer

  def init(conversations) do
    {:ok, conversations}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def initiate_conversation(manager \\ __MODULE__, initial_message) do

  end

  def end_conversation(convo_id) when is_binary(convo_id),
    do: :stuff
end
