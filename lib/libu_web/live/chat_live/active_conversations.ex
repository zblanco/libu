defmodule LibuWeb.ChatLive.ActiveConversations do
  @moduledoc """
  LiveView of Active Conversations
  """
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.{Chat, Messaging}
  alias Libu.Chat.Events.ActiveConversationAdded

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, conversations: Chat.active_conversations())
  end

  def render(assigns) do
    ChatView.render("active_conversations.html", assigns)
  end

  def handle_info(%ActiveConversationAdded{} = event, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
