defmodule Libu.Identity.Events.UserRegistered do
  @moduledoc """
  Event published to `Messaging` when a user is registered.

  We can consume this event to process the avatar url, log, or update a liveview.
  """
  alias Libu.Identity.User
  defstruct [
    :user_id,
    :avatar_url,
    :registered_on,
  ]

  def new(%User{} = user) do
    %__MODULE__{
      user_id: user.id,
      avatar_url: user.avatar_url,
      registered_on: user.inserted_at,
    }
  end
end
