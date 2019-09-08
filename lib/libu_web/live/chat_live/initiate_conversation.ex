defmodule LibuWeb.ChatLive.InitiateConversation do
  use Phoenix.LiveView

  alias LibuWeb.ChatLive
  alias LibuWeb.Router.Helpers, as: Routes
  alias Libu.Chat
  alias Libu.Chat.Commands.InitiateConversation

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       changeset: Chat.initiate_conversation(%{}, form: true)
     })}
  end

  def render(assigns), do: LibuWeb.ChatView.render("initiate_conversation.html", assigns)

  def handle_event("validate", %{"new_conversation" => params}, socket) do
    changeset =
      params
      |> Chat.initiate_conversation(form: true)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"new_conversation" => convo_params}, socket) do
    case Chat.initiate_conversation(convo_params) do
      {:ok, convo} ->
        {:stop,
         socket
         |> put_flash(:info, "conversation intiated")
         |> redirect(to: Routes.live_path(socket, ChatLive.Conversation, convo))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
