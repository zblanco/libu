defmodule Libu.Chat.Query do
  @moduledoc """
  Query responsibilities for our Chat context.

  Interface in front of the Chat interface that hides the :ets/Process details.

  Things we'd like to do:

  * Make sure we have a queryable list of active conversations
  * Fetch messages of a conversation by indexes
  """
  import Ecto.Query, warn: false
  alias Libu.{
    Repo,
    Chat.ConversationProjector,
  }

  def conversation(convo_id, start_index, end_index) when is_integer(start_index) and is_integer(end_index) do
    ConversationProjector.fetch_messages(convo_id, start_index, end_index)
  end

  def active_conversation(convo_id) do
    # fetch ActiveConversation from Projector state
  end

  def active_conversations() do
    :ets.match_object(:active_conversations, {:"$0", :"$1"})
    |> Enum.map(fn {_, msg} -> msg end)
  end
end
