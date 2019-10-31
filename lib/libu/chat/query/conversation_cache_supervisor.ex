defmodule Libu.Chat.Query.ConversationCacheSupervisor do
  use DynamicSupervisor

  alias Libu.Chat.Query.ConversationCache

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_conversation_cache(convo_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {ConversationCache, convo_id}
    )
  end

  def is_conversation_caching?(convo_id) do
    case find_conversation_cache(convo_id) do
      nil          -> false
      _pid_or_name -> true
    end
  end

  defp find_conversation_cache(convo_id) do
    convo_id
    |> ConversationCache.via()
    |> GenServer.whereis()
  end

  def stop_conversation_cache(convo_id) do
    case find_conversation_cache(convo_id) do
      nil -> {:error, :conversation_not_active}
      {_, _node} -> :error
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end

