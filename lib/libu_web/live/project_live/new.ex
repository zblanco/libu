defmodule LibuWeb.ProjectLive.New do
  use Phoenix.LiveView

  alias LibuWeb.ProjectLive
  alias LibuWeb.Router.Helpers, as: Routes
  alias Libu.ProjectManagement
  alias Libu.ProjectManagement.Project

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       count: 0,
       changeset: ProjectManagement.change_project(%Project{})
     })}
  end

  def render(assigns), do: LibuWeb.ProjectView.render("new.html", assigns)

  def handle_event("validate", %{"project" => params}, socket) do
    changeset =
      %Project{}
      |> Libu.ProjectManagement.change_project(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    case ProjectManagement.create_project(project_params) do
      {:ok, project} ->
        {:stop,
         socket
         |> put_flash(:info, "project created")
         |> redirect(to: Routes.live_path(socket, ProjectLive.Show, project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
