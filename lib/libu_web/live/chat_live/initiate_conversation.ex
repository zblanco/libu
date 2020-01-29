defmodule LibuWeb.ChatLive.InitiateConversation do
  use Phoenix.LiveView
  alias LibuWeb.Router.Helpers, as: Routes
  alias Libu.Chat

  def mount(_params, %{current_user: current_user}, socket) do
    {:ok,
     assign(socket, %{
       current_user: current_user,
       changeset: Chat.initiate_conversation(%{}, form: true)
     })}
  end

  def render(assigns), do: LibuWeb.ChatView.render("new_conversation_form.html", assigns)

  def handle_event("validate", %{"initiate_conversation" => params}, socket) do
    changeset =
      params
      |> Chat.initiate_conversation(form: true)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"initiate_conversation" => convo_params}, socket) do
    case Chat.initiate_conversation(convo_params) do
      {:ok, convo_id} ->
        {:stop,
         socket
         |> put_flash(:info, "conversation intiated")
         |> redirect(to: Routes.chat_path(socket, :conversation, convo_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
