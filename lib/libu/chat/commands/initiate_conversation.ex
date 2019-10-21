defmodule Libu.Chat.Commands.InitiateConversation do
  @moduledoc """
  Command Struct to validate an intention to initiate a conversation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w(initiator_id initiator_name message title)a

  @primary_key false
  embedded_schema do
    field :conversation_id, :string
    field :initiator_id, :integer
    field :initiator_name, :string
    field :message, :string
    field :title, :string
  end

  def new(attrs) do
    cmd = changeset(attrs)
    case cmd.valid? do
      true  -> {:ok, apply_changes(cmd)}
      false -> cmd
    end
  end

  def new(attrs, form: true), do: form_changeset(attrs)

  defp form_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_length(:title, min: 3, max: 100)
  end

  defp changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_length(:title, min: 3, max: 100)
    |> put_change(:conversation_id, UUID.uuid4())
  end
end
