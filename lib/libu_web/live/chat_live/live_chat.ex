defmodule LibuWeb.LiveChat do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, assign(socket, conversations: Chat.demo_conversations())}
  end

  def render(assigns) do
    ChatView.render("live_chat.html", assigns)
  end

end
