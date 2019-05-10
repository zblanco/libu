defmodule LibuWeb.ProjectLive.Index do
  @moduledoc """
  Index View for Projects
  """
  use Phoenix.LiveView

  alias Libu.ProjectManagement
  alias LibuWeb.ProjectView

  def mount(_session, socket) do
    if connected?(socket), do: Libu.ProjectManagement.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns), do: ProjectView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, projects: ProjectManagement.list_projects())
  end

  def handle_info({ProjectManagement, [:project | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_project", id, socket) do
    project = ProjectManagement.get_project!(id)
    {:ok, _project} = ProjectManagement.delete_project(project)

    {:noreply, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, assign(socket, query: query, page: 1)}
  end
end
