defmodule Libu.Chat.Commands.AddToConversation do
  @moduledoc """
  Command Struct to validate an intention to add to a conversation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :conversation_id, :string
    field :message, :string
    field :publisher_id, :string
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
    |> cast(attrs, [:conversation_id, :message, :publisher_id])
    |> validate_required([:initiator_id, :initial_message, :topic])
  end
end
