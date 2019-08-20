defmodule Libu.Chat.Query do
  @moduledoc """
  Query responsibilities for our Chat context.

  Interface in front of the Chat interface that hides the :ets/Process details.

  Things we'd like to do:

  * Make sure we have a queryable list of active conversations
  * Stream a conversation by cursor caching
  """
  import Ecto.Query, warn: false
  alias Libu.{
    Repo,
    Chat.ConversationProjector,
  }

  def conversation(id) when is_binary(id) do
    ConversationProjector.get_messages(id)
  end

  # def message(id) when is_binary(id) do
  #   Repo.get!(Chat.Message, id)
  # end

  def active_conversations() do
    :ets.match_object(:active_conversations, {:"$0", :"$1"})
  end

  def stream_conversation(index_start, index_end) do
    # cache conversations to ets
  end
end
