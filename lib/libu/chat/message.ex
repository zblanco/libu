defmodule Libu.Chat.Message do
  @moduledoc """
  A message published as part of a conversation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :publisher_id, :string
    field :body, :string
    field :published_on, :utc_datetime
    field :conversation_id, :string
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
    |> cast(attrs, [:id, :conversation_id, :publisher_id, :body])
    |> validate_required([:id, :publisher_id, :body])
    |> put_change(:published_on, DateTime.utc_now())
  end
end
