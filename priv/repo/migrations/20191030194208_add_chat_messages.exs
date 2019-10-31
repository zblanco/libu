defmodule Libu.Repo.Migrations.AddChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:conversation_id, :uuid)
      add(:publisher_id, :integer)
      add(:message_number, :integer)
      add(:published_on, :utc_datetime_usec)
      add(:publisher_name, :text)
      add(:body, :text)

      timestamps()
    end

    create(unique_index(:chat_messages, [:id]))
    create(index(:chat_messages, [:conversation_id]))
    create(index(:chat_messages, [:message_number]))
    create(index(:chat_messages, [:published_on]))
    create(index(:chat_messages, [:publisher_id]))
  end
end
