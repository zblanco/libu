defmodule LibuWeb.ChatLive.Show do
  use LibuWeb, :live_view
  alias Libu.Chat

  alias Libu.Chat.Events.{
    MessageReadyForQuery
  }

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    Chat.subscribe(id)

    {:noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:conversation, fetch_conversation(id))
      |> assign(:message_changeset, Chat.add_to_conversation(%{}, form: true))
      |> assign(:messages, fetch_messages(id))
    }
  end

  defp page_title(:show), do: "Libu Conversation"

  defp fetch_conversation(convo_id) do
    with {:ok, conversation} <- Chat.fetch_conversation(convo_id) do
      conversation
    end
  end

  defp fetch_messages(convo_id) do
    with {:ok, messages} <- Chat.fetch_messages(convo_id, 1, 20) do
      messages
    else
      _ -> []
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

  def handle_info(%MessageReadyForQuery{} = event, %{assigns: %{messages: messages, conversation: %{id: convo_id}}} = socket) do
    with {:ok, message} <- Chat.fetch_message(convo_id, event.message_number) do
      appended_messages = messages ++ [message]
      {:noreply, assign(socket, messages: appended_messages, conversation: fetch_conversation(convo_id))}
    else
      _other ->
        {:noreply, socket}
    end
  end

  def handle_info(_event, socket) do
    {:noreply, socket}
  end
end
