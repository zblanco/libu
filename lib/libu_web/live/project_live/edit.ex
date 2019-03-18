defmodule LibuWeb.ProjectLive.Edit do
  use Phoenix.LiveView

  alias LibuWeb.ProjectLive
  alias LibuWeb.Router.Helpers, as: Routes
  alias Libu.ProjectManagement

  def mount(%{path_params: %{"id" => id}}, socket) do
    project = ProjectManagement.get_project!(id)

    {:ok,
     assign(socket, %{
       project: project,
       changeset: ProjectManagement.change_project(project)
     })}
  end

  def render(assigns), do: LibuWeb.ProjectView.render("edit.html", assigns)

  def handle_event("validate", %{"project" => params}, socket) do
    changeset =
      socket.assigns.project
      |> Libu.ProjectManagement.change_project(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    case ProjectManagement.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        {:stop,
         socket
         |> put_flash(:info, "Project updated successfully.")
         |> redirect(to: Routes.live_path(socket, ProjectLive.Show, project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
