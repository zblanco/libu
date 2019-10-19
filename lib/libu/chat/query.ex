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
    Chat.ConversationProjector,
    Chat.ActiveConversationProjector,
  }

  def fetch_messages(convo_id, start_index, end_index)
  when is_integer(start_index)
  and is_integer(end_index) do
    ConversationProjector.fetch_messages(convo_id, start_index, end_index)
  end

  def fetch_message(convo_id, message_number) do
    ConversationProjector.fetch_message(convo_id, message_number)
  end

  def active_conversation(convo_id) do
    ActiveConversationProjector.fetch_active_conversation(convo_id)
  end

  def active_conversations() do
    ActiveConversationProjector.fetch_active_conversations()
  end
end
