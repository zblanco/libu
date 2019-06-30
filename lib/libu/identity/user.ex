defmodule Libu.Identity.User do
  @moduledoc """

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :github_id, :integer
    field :avatar_url, :string

    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:github_id, :avatar_url])
    |> unique_constraint(:github_id)
  end
end
