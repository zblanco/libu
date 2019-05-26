defmodule Libu.Identity do
  @moduledoc """
  Context module to manage users, profiles, sessions, and their authentication.
  """
  alias Libu.Identity.User
  import Ecto.Query
  alias Libu.Repo

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(attrs \\ %{}) do
    User.changeset(user, %{})
  end

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def login_user() do

  end
end
