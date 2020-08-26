defmodule Libu.Storage do
  @doc """
  Cleanup persistence for tests.
  """

  def reset! do
    reset_evenstore()
    reset_readstore()
  end

  defp reset_evenstore do
    config =
      Libu.Chat.EventStore.config()
      |> EventStore.Config.default_postgrex_opts()

    {:ok, conn} = Postgrex.start_link(config)

    EventStore.Storage.Initializer.reset!(conn)
  end

  defp reset_readstore do
    config = Application.get_env(:libu, Libu.Repo)

    {:ok, conn} = Postgrex.start_link(config)

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      chat_conversations
      chat_messages
      projection_versions
    RESTART IDENTITY
    CASCADE;
    """
  end
end
