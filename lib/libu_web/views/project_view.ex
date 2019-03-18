defmodule LibuWeb.ProjectView do
  use LibuWeb, :view

  def projects_for_status(%{} = projects_by_status, status) when is_binary(status) do
    Map.get(projects_by_status, status, [])
  end

  alias LibuWeb.ProjectLive
end
