defmodule Libu.Chat.Query.Schemas.Message do
  @moduledoc """
  Database Schema for a Message
  """
  use Ecto.Schema
  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
  }

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "chat_messages" do
    field :body, :string
    field :message_number, :integer
    field :published_on, :utc_datetime_usec
    field :publisher_name, :string
    field :conversation_id, :binary_id
    field :publisher_id, :integer

    timestamps()
  end

  def new(%ConversationStarted{} = convo_started, event_id) do
    Ecto.Changeset.change(%__MODULE__{
      id: event_id,
      conversation_id: convo_started.conversation_id,
      body: convo_started.initial_message,
      message_number: 1,
      published_on: convo_started.started_on,
      publisher_name: convo_started.initiated_by,
      publisher_id: convo_started.initiated_by_id,
    })
  end

  def new(%MessageAddedToConversation{} = msg_added, event_id) do
    Ecto.Changeset.change(%__MODULE__{
      id: event_id,
      conversation_id: msg_added.conversation_id,
      body: msg_added.message,
      message_number: msg_added.message_number,
      published_on: msg_added.added_on,
      publisher_name: msg_added.publisher_name,
      publisher_id: msg_added.publisher_id,
    })
  end
end
