defmodule LibuWeb.ChatController do
  use LibuWeb, :controller

  plug :authenticate when action in [:conversation]

  def conversation(conn, %{"id" => id}) do
    render(conn, "conversation_page.html", conversation_id: id, current_user: get_session(conn, :current_user))
  end

  defp authenticate(conn, _opts) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> redirect(to: "/auth/github")
        |> halt()
      _current_user ->
        conn
    end
  end
end
