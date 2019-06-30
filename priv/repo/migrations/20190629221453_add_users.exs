defmodule Libu.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :github_id, :integer
      add :avatar_url, :string

      timestamps()
    end

    create unique_index(:users, [:github_id])
  end
end
