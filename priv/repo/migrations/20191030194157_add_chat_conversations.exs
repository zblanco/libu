defmodule Libu.Repo.Migrations.AddChatConversations do
  use Ecto.Migration

  def change do
    create table(:chat_conversations, primary_key: false) do
      add(:conversation_id, :uuid, primary_key: true)
      add(:title, :text)
      add(:message_count, :integer)
      add(:latest_activity, :utc_datetime_usec)
      add(:initiated_on, :utc_datetime_usec)
      add(:initiator_name, :text)
      add(:initiator_id, :integer)
      add(:initial_message_body, :text)
      add(:latest_message_body, :text)
      add(:latest_publisher_id, :integer)
      add(:latest_publisher_name, :text)

      timestamps()
    end

    create(index(:chat_conversations, [:initiator_name]))
    create(index(:chat_conversations, [:initiator_id]))
    create(index(:chat_conversations, [:title]))
    create(index(:chat_conversations, [:initiated_on]))
    create(index(:chat_conversations, [:latest_activity]))
  end
end
