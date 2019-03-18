defmodule LibuWeb.PageController do
  use LibuWeb, :controller

  # plug :put_layout, :demo

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
