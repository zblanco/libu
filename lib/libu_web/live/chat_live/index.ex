defmodule LibuWeb.ChatLive.Index do
  @moduledoc """
  Shows a list of active conversations.

  Todo:

  * Add pagination
  * Convert to table

  """
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat
  alias Libu.Chat.Events.ActiveConversationAdded

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, conversations: Chat.list_conversations())
  end

  def render(assigns) do
    ChatView.render("index.html", assigns)
  end

  def handle_info(%ActiveConversationAdded{}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
