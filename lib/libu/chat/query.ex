defmodule Libu.Chat.Query do
  import Ecto.Query, warn: false
  alias Libu.{
    Repo,
    Libu.Chat.Conversation,
  }

  def conversation(id) when is_binary(id) do
    Repo.get!(Conversation, id)
  end

  # def message(id) when is_binary(id) do
  #   Repo.get!(Chat.Message, id)
  # end

  def active_conversations() do
    # check
  end

  def stream_conversation(index_start, index_end) do
    # cache conversations to ets
  end
end
