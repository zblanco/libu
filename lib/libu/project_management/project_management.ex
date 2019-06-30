defmodule Libu.ProjectManagement do
  @moduledoc """
  ### Notes:
  This started as a quick way to try out Liveview + CRUD to render a kanban board.

  A more useful feature would be to submit, post, comment, and vote on other Liveview projects.
  """
  import Ecto.Query, warn: false
  alias Libu.Repo

  alias Libu.ProjectManagement.Project
  alias Libu.Messaging

  def topic, do: inspect(__MODULE__)

  def subscribe, do: Messaging.subscribe(topic())

  def subscribe(id),
    do: Messaging.subscribe(topic() <> "#{id}")

  def projects_by_status() do
    Project
    |> Repo.all()
    |> Enum.group_by(fn %Project{status: status} -> status end)
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:project, :created])
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:project, :updated])
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    project
    |> Repo.delete()
    |> notify_subscribers([:project, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Messaging.publish({__MODULE__, event, result}, topic())
    Messaging.publish({__MODULE__, event, result}, topic() <> "#{result.id}")
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
