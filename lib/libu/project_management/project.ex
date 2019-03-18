defmodule Libu.ProjectManagement.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :status, :description])
    |> validate_required([:name, :status, :description])
    |> validate_status()
  end

  defp validate_status(changeset) do
    if get_field(changeset, :status) in status_options() do
      changeset
    else
      add_error(changeset, :status, "invalid status option")
    end
  end

  def status_options do
    [
      "Not Started",
      "In Progress",
      "On Hold",
      "Complete",
    ]
  end
end
