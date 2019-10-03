defmodule LibuWeb.ChatLive.Conversation do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat
  alias Phoenix.LiveView.Socket

  defp demo_conversation, do: %{
    id: UUID.uuid4(),
    messages: [
      %{
        published_by: "zblanco",
        body: "Anyone like LiveView?",
        published_on: DateTime.utc_now(),
      },
      %{
        published_by: "Someone",
        body: "I do!",
        published_on: DateTime.utc_now(),
      },
      %{
        published_by: "Hater",
        body: "It's okay.",
        published_on: DateTime.utc_now(),
      },
    ],
    initated_on: DateTime.utc_now(),
    initiated_by: "Doops",
    last_activity: DateTime.utc_now(),
  }

  def demo_user(), do: %{
    id: "zblanco",
    first_name: "Zack",
    last_name: "White",
  }

  def mount(%{path_params: %{"id" => id}}, socket) do
    if connected?(socket), do: Chat.subscribe(id)

    {:ok, assign(socket,
      convo_id: id,
      conversation: demo_conversation(),
      current_user: demo_user(),
      new_message: Chat.add_to_conversation(%{}, form: true)
    )}
  end

  def handle_event("keydown", %{"code" => "Enter"}, socket) do
    {:noreply, socket}
  end

  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  # def handle_info(%Chat.Events.MessagePublished{}, socket) do
    # fetch new messages within scope
  #   {:noreply, socket}
  # end

  # defp fetch(%Socket{assigns: %{id: id}} = socket) do
  #   assign(socket, conversation: Chat.get_conversation(id))
  # end

  def render(assigns) do
    ChatView.render("conversation.html", assigns)
  end

end
