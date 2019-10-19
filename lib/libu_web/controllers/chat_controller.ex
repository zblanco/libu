defmodule LibuWeb.ChatController do
  use LibuWeb, :controller

  def conversation(conn, %{"id" => id}) do
    render(conn, "conversation_page.html", conversation_id: id)
  end
end
