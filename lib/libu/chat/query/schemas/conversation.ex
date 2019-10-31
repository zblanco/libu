defmodule Libu.Chat.Query.Schemas.Conversation do
  @moduledoc """
  Database Schema for a Conversation.
  """
  use Ecto.Schema
  alias Libu.Chat.Events.{ConversationStarted, MessageAddedToConversation}

  @primary_key {:conversation_id, :binary_id, autogenerate: false}
  schema "chat_conversations" do
    field :title, :string
    field :message_count, :integer
    field :latest_activity, :utc_datetime_usec
    field :initiated_on, :utc_datetime_usec
    field :initiator_name, :string
    field :initiator_id, :integer
    field :initial_message_body, :string
    field :latest_message_body, :string
    field :latest_publisher_id, :string
    field :latest_publisher_name, :string

    timestamps()
  end

  def new(%ConversationStarted{} = convo_started) do
    Ecto.Changeset.change(%__MODULE__{
      conversation_id: convo_started.conversation_id,
      title: convo_started.title,
      message_count: 1,
      latest_activity: convo_started.started_on,
      initiator_name: convo_started.initiated_by,
      initiator_id: convo_started.initiated_by_id,
      initial_message_body: convo_started.initial_message,
      latest_message_body: convo_started.initial_message,
    })
  end

  def changes_for_message_added(%MessageAddedToConversation{} = msg_added) do
    Ecto.Changeset.change(%__MODULE__{
      conversation_id: msg_added.conversation_id,
      latest_publisher_id: msg_added.publisher_id,
      latest_message_body: msg_added.message,
      latest_activity: msg_added.added_on,
      latest_publisher_name: msg_added.publisher_name,
      message_count: msg_added.message_number,
    })
  end
end
