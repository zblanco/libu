defmodule LibuWeb.ChatLive.Conversation do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat
  alias Phoenix.LiveView.Socket

  alias Libu.Chat.Events.{
    MessageReadyForQuery
  }

  def mount(%{path_params: %{"id" => convo_id}} = session, %Socket{} = socket),
    do: mount(%{session | conversation_id: convo_id}, socket)
  def mount(%{conversation_id: convo_id, current_user: current_user} = session, socket) do
    if connected?(socket) do

      IO.inspect(session, label: "mounted session for conversation")
      Chat.subscribe(convo_id)

      {:ok,
       assign(socket,
         convo_id: convo_id,
         current_user: current_user,
         message_changeset: Chat.add_to_conversation(%{}, form: true)
       )
       |> fetch_active_conversation(convo_id)
       |> fetch_messages(convo_id)}
    else

      {:ok,
       assign(socket,
         convo_id: convo_id,
         conversation: demo_conversation(),
         messages: %{},
         current_user: demo_user(),
         message_changeset: Chat.add_to_conversation(%{}, form: true)
       )}
    end
  end

  def render(assigns) do
    ChatView.render("conversation.html", assigns)
  end

  defp fetch_active_conversation(socket, convo_id) do
    with {:ok, conversation} <- Chat.fetch_active_conversation(convo_id) do
      assign(socket, conversation: conversation)
    else
      _ ->
        IO.puts("error fetching active conversation: #{convo_id}")
        socket
    end
  end

  defp fetch_messages(socket, convo_id) do
    with {:ok, messages} <- Chat.fetch_messages(convo_id, 1, 20) do
      assign(socket, messages: messages)
    else
      _ -> socket
    end
  end

  def handle_event("keydown", %{"code" => "Enter"} = keydown_msg, socket) do
    IO.puts("Enter key pressed!")
    IO.inspect(keydown_msg, label: "keydown_msg")
    {:noreply, socket}
  end

  def handle_event("new_message", %{"new_message" => msg_params}, socket) do
    IO.puts("handling submit!")
    IO.inspect(msg_params)

    socket =
      case Chat.add_to_conversation(msg_params) do
        :ok ->
          assign(socket, message_changeset: Chat.add_to_conversation(%{}, form: true))

        error_changeset ->
          assign(socket, message_changeset: error_changeset)
      end

    {:noreply, assign(socket, message_changeset: Chat.add_to_conversation(%{}, form: true))}
  end

  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info(%MessageReadyForQuery{} = event,
    %Socket{assigns: %{messages: messages, convo_id: convo_id}} = socket
  ) do
    # if conversation message count is far off, query all missed events
    # if just one event is missing, fetch (it should be cached)
    # the important thing is that the events fetched are in order
    with {:ok, message} <- Chat.fetch_message(convo_id, event.message_number) do
      appended_messages = messages ++ [message]
      {:noreply, assign(socket, messages: appended_messages) |> fetch_active_conversation(convo_id)}
    else
      other ->
        IO.inspect(other, label: "erronious return from fetch_message/2")
        {:noreply, socket}
    end
  end

  def handle_info(event, socket) do
    IO.inspect(event, label: "Conversation LiveView handling an event:")
    {:noreply, socket}
  end

  defp demo_conversation,
    do: %{
      conversation_id: UUID.uuid4(),
      message_count: 2,
      latest_activity: DateTime.utc_now(),
      initial_message: %{
        event_id: UUID.uuid4(),
        publisher_id: "zblanco",
        publisher: "Zack White",
        body: "Anyone like LiveView?",
        published_on: DateTime.utc_now(),
        message_number: 1,
      },
      latest_message: %{
        event_id: UUID.uuid4(),
        publisher_id: "doops",
        publisher: "The Doops",
        body: "I do!",
        published_on: DateTime.utc_now(),
        message_number: 2,
      }
    }

  defp demo_user(),
    do: %{
      id: "zblanco",
      name: "Zack",
    }
end
