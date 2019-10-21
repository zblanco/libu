defmodule LibuWeb.IdentityController do
  use LibuWeb, :controller
  require Logger

  alias Libu.Identity.{GithubAuth, User}
  alias Libu.Identity

  def index(conn, %{"provider" => "github"}) do
    redirect(conn, external: GithubAuth.authorize_url!)
  end

  def end_session(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  # consider extracting into a plug
  def callback(conn, %{"provider" => provider, "code" => code}) do
    client      = get_token!(provider, code)
    github_user = get_user!(provider, client)

    current_user =
      case Identity.get_user_by(github_id: github_user.github_id) do
        nil ->
          {:ok, user} = Identity.register_user(github_user)
          user
        %User{} = user -> user
      end

    conn
    |> put_session(:current_user, current_user)
    # |> put_session(:access_token, client.token.access_token) # we might not need the access token in session unless we want to access repo information on behalf of users
    |> redirect(to: "/chat") # authentication should be required only for chat, so we need to return to previous page?
  end

  defp get_token!("github", code), do: GithubAuth.get_token!(code: code)

  defp get_user!("github", client) do
    %{body: user} = OAuth2.Client.get!(client, "/user")
    %{github_id: user["id"], name: user["name"], avatar_url: user["avatar_url"]}
  end

end
