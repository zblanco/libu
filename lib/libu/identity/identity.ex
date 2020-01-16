defmodule Libu.Identity do
  @moduledoc """
  - [x] Authenticate via OAuth2 with Github
  - [x] Persist to Ecto a user struct storing a github user id of some kind.
  - [ ] Keep session states in-memory.
  """
  alias Libu.{
    Repo,
    Messaging,
    Identity.User,
    Identity.Events.UserRegistered,
  }

  def topic, do: inspect(__MODULE__)

  def subscribe, do: Messaging.subscribe(topic())

  def subscribe(user_id),
    do: Messaging.subscribe(topic() <> ":#{user_id}")

  def get_user(id),
    do: Repo.get_by(User, github_id: id)

  def list_users(), do: Repo.all(User)

  def register_user(attrs \\ %{}) do
    with {:ok, user} <-
      %User{}
      |> User.registration_changeset(attrs)
      |> Repo.insert()
    do
      user
      |> UserRegistered.new()
      |> Messaging.publish(topic())

    {:ok, user}
    else
      error -> error
    end
  end
end
