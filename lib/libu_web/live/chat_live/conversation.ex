defmodule LibuWeb.ChatLive.Conversation do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat
  alias Phoenix.LiveView.Socket

  defp demo_conversation, do: %{
    id: UUID.uuid4(),
    messages: [
      %{
        published_by: "Doops",
        body: "Anyone like LiveView?",
        published_on: DateTime.utc_now(),
      },
      %{
        published_by: "Someone",
        body: "I do!",
        published_on: DateTime.utc_now(),
      },
    ],
    initated_on: DateTime.utc_now(),
    initiated_by: "Doops",
    last_activity: DateTime.utc_now(),
  }

  # def mount(%{path_params: %{"id" => id}}, socket) do
  #   if connected?(socket), do: Chat.subscribe(id)
  #   {:ok, fetch(assign(socket, id: id))}
  # end

  def mount(_, socket) do
    # if connected?(socket), do: Chat.subscribe(id)
    {:ok, assign(socket, conversation: demo_conversation())}
  end

  # defp fetch(%Socket{assigns: %{id: id}} = socket) do
  #   assign(socket, conversation: Chat.get_conversation(id))
  # end

  def render(assigns) do
    ChatView.render("conversation.html", assigns)
  end

end
