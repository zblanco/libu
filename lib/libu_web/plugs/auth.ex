defmodule LibuWeb.Plugs.Auth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> get_session(:current_user)
    |> case do
      nil ->
        conn
        |> Phoenix.Controller.redirect(
          to: LibuWeb.Router.Helpers.identity_path(conn, :index, "github"))
        |> halt()

      _current_user ->
        conn
    end
  end
end
