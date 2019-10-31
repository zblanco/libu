defmodule Libu.Chat.Query.ConversationCacheManager do
  @moduledoc """
  Manages a named ETS table that holds references to conversation projector tables.

  Monitors ConversationProjectors to prune references.

  TODO

  * lifecycle of the active_projector table
  * monitor conversation_projectors for unknown failures
  * handle normal projector endings
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(_opts) do
    _tid = :ets.new(:cached_conversations, [:named_table, :set, :public])
    {:ok, []}
  end

  def caching_projecting_conversations() do
    :ets.tab2list(:cached_conversations)
  end

  def notify_of_caching_conversation(conversation_id, cache_table) do
    :ets.insert_new(:cached_conversations, {conversation_id, {cache_table, DateTime.utc_now()}})
    :ok
  end

  def get_cache_table(conversation_id) do
    [{_convo_id, {cache, _timestamp}}] = :ets.lookup(:cached_conversations, conversation_id)
    cache
  end

  def notify_of_deactivated_conversation(conversation_id) do
    :ets.delete(:cached_conversations, conversation_id)
  end
end
