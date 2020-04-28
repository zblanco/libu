defmodule LibuWeb.ChatLive.Index do
  @moduledoc """
  Shows a list of active conversations.

  Todo:

  * Add pagination
  * Convert to table

  """
  use LibuWeb, :live_view
  alias Libu.Chat
  alias Libu.Chat.Events.ActiveConversationAdded

  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, handle_action(socket.assigns.live_action, params, socket)}
  end

  defp handle_action(:initiate_conversation, _params, socket) do
    socket
    |> assign(:page_title, "Initiate Conversation")
    |> assign(:initiate_conversation_changeset, Chat.initiate_conversation(%{}, form: true))
    |> assign(:conversations, &fetch_conversations/0)
  end

  defp handle_action(:index, _params, socket) do
    socket
    |> assign(:page_title, "Listing Conversations")
    |> assign(conversations: fetch_conversations())
  end

  def handle_info(%ActiveConversationAdded{}, socket) do
    {:noreply, assign(socket, :conversations, fetch_conversations())}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def fetch_conversations do
    Chat.list_conversations()
  end
end
