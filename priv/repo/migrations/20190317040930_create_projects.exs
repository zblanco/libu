defmodule Libu.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :status, :string
      add :description, :string

      timestamps()
    end

    create index(:projects, [:board_id])
  end
end
