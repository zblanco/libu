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
    Chat.Query.ConversationCache,
    Chat.Query.ConversationCacheSupervisor,
    Chat.Query.Schemas.Person,
    Chat.Query.Schemas.Conversation,
  }

  alias Libu.Repo

  def fetch_messages(convo_id, start_index, end_index)
  when is_integer(start_index)
  and is_integer(end_index) do
    fetch_messages(convo_id, start_index..end_index |> Enum.to_list())
  end

  def fetch_messages(convo_id, msg_numbers)
  when is_list(msg_numbers)
  do
    with :ok  <- is_valid_conversation_id?(convo_id),
         true <- ConversationCacheSupervisor.is_conversation_caching?(convo_id)
    do
      do_fetch_messages(convo_id, msg_numbers)
    else
      {:error, :invalid_conversation} = error ->
        error

      false ->
        ConversationCacheSupervisor.start_conversation_cache(convo_id)
        do_fetch_messages(convo_id, msg_numbers)
    end
  end

  defp do_fetch_messages(convo_id, message_numbers),
    do: ConversationCache.fetch_messages(convo_id, message_numbers)

  defp do_fetch_message(convo_id, message_number),
    do: ConversationCache.fetch_message(convo_id, message_number)

  defp is_valid_conversation_id?(convo_id) do
    # case Repo.one(Queries.fetch_conversation(convo_id)) do
    #   {:ok, _convo} ->
    #     :ok
    #   {:error, :conversation_not_found} ->
    #     {:error, :invalid_conversation}
    # end
    :ok
  end

  def fetch_message(convo_id, msg_number) do
    with :ok  <- is_valid_conversation_id?(convo_id),
         true <- ConversationCacheSupervisor.is_conversation_caching?(convo_id)
    do
      do_fetch_message(convo_id, msg_number)
    else
      {:error, :invalid_conversation} = error ->
        error

      false ->
        ConversationCacheSupervisor.start_conversation_cache(convo_id)
        do_fetch_message(convo_id, msg_number)
    end
  end

  def list_conversations() do
    Repo.all(Conversation)
  end

  def fetch_conversation(conversation_id) do
    case Repo.get(Conversation, conversation_id) do
      nil          -> {:error, :conversation_not_found}
      conversation -> {:ok, conversation}
    end
  end

  def get_person(person_id) do
    case Repo.get(Person, person_id) do
      nil    -> {:error, :person_not_found}
      person -> {:ok, person}
    end
  end
end
