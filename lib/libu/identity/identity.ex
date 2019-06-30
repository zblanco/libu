defmodule Libu.Identity do
  @moduledoc """

  Registration:
  * Redirect to Login with Github
  * If no user created for Github id

  ### Capabilities to implemement:

  * Authenticate via OAuth2 with Github
  * Persist to Ecto a user struct storing a github user id over some kind.
  * Keep session states in-memory.
  * transform and persist the avatar url for use across app
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

  def get_user_by(github_id: github_id),
    do: Repo.get_by(User, github_id: github_id)

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
