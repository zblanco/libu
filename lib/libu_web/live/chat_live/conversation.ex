defmodule LibuWeb.Conversation do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat
  alias Phoenix.LiveView.Socket

  def mount(%{path_params: %{"id" => id}}, socket) do
    if connected?(socket), do: Chat.subscribe(id)
    {:ok, fetch(assign(socket, id: id))}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, conversation: Chat.get_conversation(id))
  end

  def render(assigns) do
    ChatView.render("conversation.html", assigns)
  end

end
