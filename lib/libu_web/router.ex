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
    # plug LibuWeb.StickySession # ensure we have a session_uuid

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

    live "/chat", ChatLive.Index
    live "/chat/conversations/new", ChatLive.InitiateConversation
    live "/chat/conversations/:id", ChatLive.Conversation

    live "/analysis", AnalysisSession, session: [:uuid]

    resources "/plain/projects", ProjectController
  end

  scope "/auth", LibuWeb do
    pipe_through :browser

    get "/:provider", IdentityController, :index
    get "/:provider/callback", IdentityController, :callback
  end
end
