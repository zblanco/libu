defmodule Libu.Chat.Message do
  @moduledoc """
  A message published as part of a conversation.
  """
  defstruct [
    :publisher_id,
    :body,
    :published_on,
  ]

  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
  }

  def new(%ConversationStarted{
    initiated_by: publisher_id,
    initial_message: body,
  }) do
    %__MODULE__{
      publisher_id: publisher_id,
      body: body,
      published_on: DateTime.utc_now(),
    }
  end
end
