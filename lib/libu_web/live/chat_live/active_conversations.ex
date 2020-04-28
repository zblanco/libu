defmodule LibuWeb.ChatLive.ActiveConversations do
  @moduledoc """
  LiveView of Active Conversations
  """
  use LibuWeb, :live_view
  alias Libu.Chat
  alias Libu.Chat.Events.ActiveConversationAdded

  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, conversations: Chat.list_conversations())
  end

  def handle_info(%ActiveConversationAdded{}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
