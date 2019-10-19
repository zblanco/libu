defmodule Libu.Chat.Query.ConversationProjectionManager do
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
    _tid = :ets.new(:projecting_conversations, [:named_table, :set, :public])
    {:ok, []}
  end

  def actively_projecting_conversations() do
    :ets.tab2list(:projecting_conversations)
  end

  def notify_of_active_conversation(conversation_id, tables) do
    :ets.insert(:projecting_conversations, {conversation_id, {tables, DateTime.utc_now()}})
    :ok
  end

  def tables_of_projector(conversation_id) do
    [{_convo_id, {tables, _timestamp}}] = :ets.lookup(:projecting_conversations, conversation_id)
    tables
  end

  def notify_of_deactivated_conversation(conversation_id) do
    :ets.delete(:projecting_conversations, conversation_id)
  end
end
