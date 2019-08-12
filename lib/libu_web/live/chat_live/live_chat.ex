defmodule LibuWeb.LiveChat do
  @moduledoc """
  Shows a list of active conversations sorted by latest activity.
  """
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat

  defp demo_conversation_list, do: [
    %{
      id: UUID.uuid4(),
      initial_message: %{
        published_by: "Doops",
        body: "Anyone like LiveView?",
        published_on: DateTime.utc_now(),
      },
      initated_on: DateTime.utc_now(),
      latest_message: %{
        published_by: "Doops",
        body: "Because I do",
        published_on: DateTime.utc_now(),
      },
      initiated_by: "Doops",
      last_activity: DateTime.utc_now(),
    },
  ]

  def mount(_session, socket) do
    # if connected?(socket), do: Chat.subscribe()
    {:ok, assign(socket, conversations: demo_conversation_list())}
  end

  def render(assigns) do
    ChatView.render("live_chat.html", assigns)
  end

  # def handle_info(, socket) do
  #   {:noreply, fetch(socket)}
  # end

end
