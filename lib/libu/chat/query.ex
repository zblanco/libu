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
end
