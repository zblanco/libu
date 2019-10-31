defmodule Libu.Storage do
  @doc """
  Cleanup persistence for tests.
  """

  def reset! do
    reset_evenstore()
  end

  defp reset_evenstore do
    config =
      Libu.Chat.EventStore.config()
      |> EventStore.Config.default_postgrex_opts()

    {:ok, conn} = Postgrex.start_link(config)

    EventStore.Storage.Initializer.reset!(conn)
  end
end
