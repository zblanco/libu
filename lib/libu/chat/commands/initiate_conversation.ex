defmodule Libu.Chat.Commands.InitiateConversation do
  @moduledoc """
  Command Struct to validate an intention to initiate a conversation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :conversation_id, :string
    field :initiator_id, :string
    field :initial_message, :string
  end

  def new(attrs) do
    cmd = changeset(attrs)
    case cmd.valid? do
      true  -> {:ok, apply_changes(cmd)}
      false -> cmd
    end
  end

  def new(attrs, form: true), do: changeset(attrs)

  defp changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:initiator_id, :topic, :initial_message])
    |> validate_required([:initiator_id, :initial_message, :topic])
    |> put_change(:conversation_id, UUID.uuid4())
  end
end
