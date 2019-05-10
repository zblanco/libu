defmodule Libu.Chat.Commands.PublishMessage do
  @moduledoc """
  A message published as part of a conversation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:message_id, :binary_id, autogenerate: false}
  embedded_schema do
    field :publisher_id, :string
    field :body, :string
    field :published_on, :utc_datetime
    field :parent_id, :string
  end

  def new(attrs) do
    message_changeset = changeset(attrs)
    case message_changeset.valid? do
      true  -> {:ok, apply_changes(message_changeset)}
      false -> message_changeset
    end
  end

  def new(attrs, form: true), do: changeset(attrs)

  defp changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:conversation_id, :publisher_id, :body])
    |> validate_required([:publisher_id, :body])
    |> put_change(:published_on, DateTime.utc_now())
    |> put_change(:id, UUID.uuid4())
  end
end
