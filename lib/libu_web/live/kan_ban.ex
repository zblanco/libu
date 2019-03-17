defmodule LibuWeb.KanBan do
  @moduledoc """


  """
  use Phoenix.LiveView
  alias LibuWeb.KanBanView
  alias Libu.ProjectManagement

  def render(assigns), do: KanBanView.render("kanban.html", assigns)

  def mount(_session, socket) do
    if connected?(socket), do: ProjectManagement.subscribe()

    {:ok, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, projects: ProjectManagement.list_projects())
  end

  def handle_info({ProjectManagement, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_project", id, socket) do
    project = ProjectManagement.get_project!(id)
    {:ok, _project} = ProjectManagement.delete_project(project)

    {:noreply, socket}
  end
end
