defmodule Libu.Chat.Commands.EndConversation do
  @moduledoc """
  The intent to end a conversation and its required parameters.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :conversation_id, :string
    field :reason, :string
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
    |> cast(attrs, [:conversation_id, :reason])
    |> validate_required([:conversation_id, :reason])
  end
end
