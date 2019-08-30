defmodule LibuWeb.LiveChat do
  @moduledoc """
  Shows a list of active conversations.
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
    ChatView.render("live_chat.html", assigns)
  end

  def handle_info(%ActiveConversationAdded{} = event, socket) do
    IO.inspect(event, label: "LiveChat Index handling")
    {:noreply, fetch(socket)}
  end

  def handle_info(message, socket) do
    IO.inspect(message, label: "LiveChat catch all event handle")
    {:noreply, socket}
  end
end
