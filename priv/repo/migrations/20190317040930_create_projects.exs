defmodule Libu.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :status, :string
      add :description, :string

      timestamps()
    end
  end
end
