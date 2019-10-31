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
  def mount(%{conversation_id: convo_id, current_user: current_user}, socket) do
    if connected?(socket) do
      Chat.subscribe(convo_id)

      {:ok,
       assign(socket,
         conversation_id: convo_id,
         current_user: current_user,
         message_changeset: Chat.add_to_conversation(%{}, form: true)
       )
       |> fetch_conversation(convo_id)
       |> fetch_messages(convo_id)}
    else

      {:ok,
       assign(socket,
         conversation_id: convo_id,
         current_user: current_user,
         messages: [],
         message_changeset: Chat.add_to_conversation(%{}, form: true)
       ) |> fetch_conversation(convo_id)}
    end
  end

  def render(assigns) do
    ChatView.render("conversation.html", assigns)
  end

  defp fetch_conversation(socket, convo_id) do
    with {:ok, conversation} <- Chat.fetch_conversation(convo_id) do
      assign(socket, conversation: conversation)
    else
      _ -> redirect(socket, to: "/chat")
    end
  end

  defp fetch_messages(socket, convo_id) do
    with {:ok, messages} <- Chat.fetch_messages(convo_id, 1, 20) do
      assign(socket, messages: messages)
    else
      _ -> socket
    end
  end

  def handle_event("new_message", %{"new_message" => msg_params}, socket) do
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

  def handle_info(%MessageReadyForQuery{} = event, %Socket{assigns: %{messages: messages, conversation_id: convo_id}} = socket) do
    with {:ok, message} <- Chat.fetch_message(convo_id, event.message_number) do
      appended_messages = messages ++ [message]
      {:noreply, assign(socket, messages: appended_messages) |> fetch_conversation(convo_id)}
    else
      _other ->
        {:noreply, socket}
    end
  end


  def handle_info(_event, socket) do
    {:noreply, socket}
  end
end
