defmodule LibuWeb.ChatLive.Conversation do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat

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

  # def mount(%{path_params: %{"id" => convo_id}}, socket) do
  def mount(%{}, socket) do
    convo = demo_conversation()
    if connected?(socket) do
      # Chat.subscribe(convo_id)
      # {:ok, convo} = Chat.setup_conversation_session("Doops", convo_id)
      {:ok,
        socket
        |> assign(
          convo_id: convo.id,
          conversation: convo,
          current_user: demo_user(),
          message_changeset: Chat.add_to_conversation(%{}, form: true))
        # |> fetch_active_conversation(convo_id)
      }
    else
      {:ok, assign(socket,
        convo_id: convo.id,
        conversation: convo,
        current_user: demo_user(),
        message_changeset: Chat.add_to_conversation(%{}, form: true)
      )}
    end
  end

  # defp fetch_active_conversation(socket, convo_id) do
  #   Chat.fetch_active_conversation(convo_id)
  # end

  def handle_event("keydown", %{"code" => "Enter"} = keydown_msg, socket) do
    IO.puts "Enter key pressed!"
    IO.inspect(keydown_msg, label: "keydown_msg")
    {:noreply, socket}
  end

  def handle_event("new_message", %{"new_message" => msg_params}, socket) do
    IO.puts "handling submit!"
    IO.inspect msg_params

    socket =
      case Chat.add_to_conversation(msg_params) do
        :ok ->
          assign(socket, message_changeset: Chat.add_to_conversation(%{}, form: true))

        error_changeset ->
          assign(socket, message_changeset: error_changeset)
      end

    {:noreply, assign(socket, message_changeset: Chat.add_to_conversation(%{}, form: true))}
  end


  def handle_event("keydown", keydown_msg, socket) do
    IO.puts "Some other key was pressed!"
    IO.inspect(keydown_msg, label: "keydown_msg")
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
