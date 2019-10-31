defmodule Libu.Chat.Query.Queries do
  @moduledoc """
  Queries to the projections that don't go through a cache.
  """
  import Ecto.Query
  alias Libu.Chat.Query.Schemas.{
    Message,
    Conversation,
  }

  def fetch_conversation(convo_id) do
    {:ok, convo_id} = Ecto.UUID.cast(convo_id)
    from(m in Conversation,
      select: m,
      where: m.conversation_id == ^convo_id,
      limit: 1
    )
  end

  def fetch_latest_messages(convo_id, message_count) when is_integer(message_count) do
    {:ok, convo_id} = Ecto.UUID.cast(convo_id)
    from(m in Message,
      select: m,
      where: m.conversation_id == ^convo_id,
      order_by: [desc: m.message_number],
      limit: ^message_count
    )
  end

  def fetch_message_by_number(convo_id, message_number) when is_integer(message_number) do
    {:ok, convo_id} = Ecto.UUID.cast(convo_id)
    from(m in Message,
      select: m,
      where: m.conversation_id == ^convo_id and m.message_number == ^message_number
    )
  end

  def fetch_messages_by_number(convo_id, message_numbers) when is_list(message_numbers) do
    {:ok, convo_id} = Ecto.UUID.cast(convo_id)
    Message
    |> select([m], m)
    |> where(conversation_id: ^convo_id)
    |> where([m], m.message_number in ^message_numbers)
  end
end
