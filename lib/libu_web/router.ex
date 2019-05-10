defmodule LibuWeb.Router do
  use LibuWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {LibuWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LibuWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/projects", ProjectLive.Index
    live "/projects/kanban", ProjectLive.KanBan
    live "/projects/new", ProjectLive.New
    live "/projects/:id", ProjectLive.Show
    live "/projects/:id/edit", ProjectLive.Edit

    live "/clock", LiveClock
    live "/chat", LiveChat

    resources "/plain/projects", ProjectController
  end
end
