defmodule Libu.ProjectManagement.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:status, :description])
    |> validate_required([:status, :description])
  end
end
