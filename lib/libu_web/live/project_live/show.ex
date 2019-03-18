defmodule LibuWeb.ProjectLive.Show do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias LibuWeb.ProjectLive
  alias LibuWeb.Router.Helpers, as: Routes
  alias Libu.ProjectManagement
  alias Phoenix.LiveView.Socket

  def render(assigns), do: LibuWeb.ProjectView.render("show.html", assigns)

  def mount(%{path_params: %{"id" => id}}, socket) do
    if connected?(socket), do: Libu.ProjectManagement.subscribe(id)
    {:ok, fetch(assign(socket, id: id))}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, project: ProjectManagement.get_project!(id))
  end

  def handle_info({ProjectManagement, [:project, :updated], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({ProjectManagement, [:project, :deleted], _}, socket) do
    {:stop,
     socket
     |> put_flash(:error, "This project has been deleted from the system")
     |> redirect(to: Routes.live_path(socket, ProjectLive.Index))}
  end
end
