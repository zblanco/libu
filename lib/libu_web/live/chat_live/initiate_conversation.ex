defmodule LibuWeb.ChatLive.InitiateConversation do
  use LibuWeb, :live_component
  alias Libu.Chat

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Chat.initiate_conversation(%{}, form: true))}
  end

  def handle_event("validate", %{"initiate_conversation" => params}, socket) do
    changeset =
      params
      |> Chat.initiate_conversation(form: true)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"initiate_conversation" => convo_params}, socket) do
    case Chat.initiate_conversation(convo_params) do
      {:ok, convo_id} ->
        {:stop,
         socket
         |> put_flash(:info, "Conversation initiated")
         |> push_redirect(to: Routes.chat_show_path(socket, :show, convo_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
