defmodule Libu.Analysis.EtsQueue do
  @moduledoc """
  FIFO queue implemented with ETS Ordered Sets.
  """
  defstruct [
    :length,
    :tid,
  ]

  @type t :: %__MODULE__{
    length: integer() | nil,
    tid: any,
  }

  def new(length) when is_integer(length) do
    tid = :ets.new(__MODULE__, [:public, :ordered_set])
    %__MODULE__{tid: tid, length: length}
  end

  def new() do
    tid = :ets.new(__MODULE__, [:public, :ordered_set])
    %__MODULE__{tid: tid}
  end

  def put(%__MODULE__{tid: tid}, item) do
    key =
      case :ets.last(tid) do
        :"$end_of_table" -> 0
        counter          -> counter + 1
      end

    true = :ets.insert(tid, {key, item})
    :ok
  end

  def take(%__MODULE__{tid: tid}) do
    case :ets.first(tid) do
      :"$end_of_table" -> {:error, :empty_queue}
      first ->
        [{_key, item}] = :ets.lookup(tid, first)
        true = :ets.delete(tid, first)
        {:ok, item}
    end
  end

  def take(queue, amount) when is_integer(amount) do
    items =
      1..amount
      |> Enum.map(fn _count -> take(queue) end)
      |> Enum.map(fn item ->
        case item do
          {:error, _} -> nil
          {:ok, item} -> item
        end
      end)
      |> Enum.filter(fn item -> item != nil end)

    case Kernel.length(items) do
      0 -> {:error, :empty_queue}
      _ -> {:ok, items}
    end
  end

  def length(%__MODULE__{tid: tid}), do: :ets.info(tid, :size)

  def show_all(%__MODULE__{tid: tid}), do: :ets.tab2list(tid)

  def terminate(%__MODULE__{tid: tid}) do
    true = :ets.delete(tid)
    :ok
  end
end
