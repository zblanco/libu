defmodule Libu.Chat.Query.ConversationCache do
  @moduledoc """
  Transient Process responsible for maintaining an ETS table of a conversation.

  When all messages time-out the process shuts down.

  We re-cache from the event-store when messages that have been timed-out are requeried placing them back in their ordered location.

  TODO:

  - [x] Working conversation appending
  - [x] Cursor stream queries / write-through cache
  - [x] Re-initialization of dead/timed-out conversations by streaming in from event-store
  - [x] Implement per-message timeouts/TTLs reset upon access
  - [ ] Ensure the Cache Manager knows when a Projector's TTLs expire and it shuts down
  - [x] Utilize Cache Manager to remove read-bottlenecks that occur through Genserver callbacks
  - [x] Use Set instead of ordered set
  - [x] Put cache ttls in same state container as messages
  - [x] Key cached messages by number
  - [ ] Keep state somewhere of a counter of messages so we know bounds to query for
  - [ ] Increment messages counters and new ones arrive

  Also we don't really need the ordered set if we're keying the messages in a set by the message number.
  """
  use GenServer, restart: :transient

  alias Libu.Chat.Events.{
    MessageAddedToConversation,
  }
  alias Libu.Chat.{
    Query.Schemas.Message,
    Query.ConversationCacheManager,
    Query.Streaming,
    Query.ConversationCacheSupervisor,
    Query,
    Query.Queries,
  }
  alias Libu.{Chat, Messaging}
  alias Libu.Repo

  @default_timeout :timer.minutes(30)

  def via(convo_id) when is_binary(convo_id) do
    {:via, Registry, {Libu.Chat.ConversationCacheRegistry, {__MODULE__, convo_id}}}
  end
  def via(_convo_id), do: :non_binary_id

  def child_spec(convo_id) do
    %{
      id: {__MODULE__, convo_id},
      start: {__MODULE__, :start_link, [convo_id]},
      restart: :temporary,
    }
  end

  def start_link(convo_id) do
    GenServer.start_link(
      __MODULE__,
      convo_id,
      name: via(convo_id)
    )
  end

  def start(convo_id) do
    ConversationCacheSupervisor.start_conversation_cache(convo_id)
  end

  def init(convo_id) do
    init_state = %{
      cache: :ets.new(:cache, [:set, :public]),
      conversation_id: convo_id,
    }
    ConversationCacheManager.notify_of_caching_conversation(convo_id, init_state.cache)
    Chat.subscribe(convo_id)

    {:ok, init_state, {:continue, :init}}
  end

  def handle_continue(:init, %{conversation_id: convo_id, cache: cache} = init_state) do
    cache_latest_messages(convo_id, cache)
    schedule_purge()
    {:noreply, init_state}
  end

  defp cache_latest_messages(convo_id, cache) do
    with {:ok, messages} <- Repo.all(Queries.fetch_latest_messages(convo_id, 10)) do
      Enum.each(messages, &do_cache_message(cache, &1))
    end
  end

  defp schedule_purge do
    Process.send_after(self(), :purge, @default_timeout)
  end

  def fetch_messages(conversation_id, message_numbers) when is_list(message_numbers) do
    %{cached: cached_messages, uncached: uncached_message_numbers} =
      message_numbers
      |> Enum.map(&fetch_if_cached(&1, conversation_id))
      |> Enum.to_list()
      |> Enum.reduce(%{cached: [], uncached: []}, fn num_or_message, %{cached: cm, uncached: umn} = acc ->
        case num_or_message do
          {:ok, message} -> %{acc | cached: [message | cm]}
          msg_number     -> %{acc | uncached: [msg_number | umn]}
        end
      end)

    messages_from_storage =
      fetch_messages_from_storage(conversation_id, uncached_message_numbers)
      |> Enum.into(%{}, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    messages =
      cached_messages
      |> Enum.into(messages_from_storage, fn %{message_number: msg_no} = message -> {msg_no, message} end)

    {:ok, Map.values(messages)}
  end

  def fetch_message(conversation_id, message_number) do
    case fetch_if_cached(message_number, conversation_id) do
      {:ok, _cached_message} = return ->
        return

      _message_number ->
        message =
          Queries.fetch_message_by_number(conversation_id, message_number)
          |> Repo.one()

        cache_message(message)

        {:ok, message}
    end
  end

  def fetch_messages_from_storage(conversation_id, uncached_message_numbers) do
    cache = ConversationCacheManager.get_cache_table(conversation_id)
    Queries.fetch_messages_by_number(conversation_id, uncached_message_numbers)
    |> Repo.all()
    |> Enum.map(&do_cache_message(cache, &1))
  end

  def fetch_if_cached(message_number, conversation_id) do
    cache = ConversationCacheManager.get_cache_table(conversation_id)

    with true <- is_cached?(message_number, cache),
         {:ok, _message} = response <- fetch_from_cache(cache, message_number)
    do
      response
    else
      _ -> message_number
    end
  end

  def fetch_from_cache(cache, message_number) do
    case :ets.lookup(cache, message_number) do
      [{_msg_no, message, _last_touch, _ttl} = meta_message] ->
        requeried_meta_message =
          meta_message
          |> put_elem(2, DateTime.utc_now())

        :ets.insert(cache, requeried_meta_message)
        {:ok, message}

      _ ->
        {:error, :message_not_found_in_cache}
    end
  end

  # def handle_info(:purge, %{log: log, registry: registry} = tables) do
  #   # go through cache registry to find expired
  #   # remove from log & registry
  #   {:noreply, tables}
  # end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def cache_message(%Message{conversation_id: convo_id} = msg) do
    with true  <- ConversationCacheSupervisor.is_conversation_caching?(convo_id),
         cache <- ConversationCacheManager.get_cache_table(convo_id)
    do
      do_cache_message(cache, msg)
      :ok
    else
      false ->
        start(convo_id)
        cache = ConversationCacheManager.get_cache_table(convo_id)
        do_cache_message(cache, msg)
        :ok
    end
  end

  defp do_cache_message(tid, %Message{} = msg) do
    insert_message(tid, msg)
    msg
  end

  defp insert_message(tid, %Message{} = msg) do
    :ets.insert(tid, {msg.message_number, msg, DateTime.utc_now(), @default_timeout})
  end

  def is_cached?(message_number, registry) do
    case :ets.lookup(registry, message_number) do
      [{^message_number, _msg, _last_touch, _ttl}] -> true
      _ -> false
    end
  end
end
