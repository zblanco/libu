defmodule Libu.Chat.ConversationProjectorSupervisor do
  use DynamicSupervisor

  alias Libu.Chat.ConversationProjector

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_conversation_projector(convo_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {ConversationProjector, convo_id}
    )
  end

  def is_conversation_projecting?(convo_id) do
    case find_conversation_projector(convo_id) do
      nil          -> false
      _pid_or_name -> true
    end
  end

  defp find_conversation_projector(convo_id) do
    convo_id
    |> ConversationProjector.via()
    |> GenServer.whereis()
  end

  def stop_conversation_projector(convo_id) do
    find_conversation_projector(convo_id)
    |> (fn pid -> DynamicSupervisor.terminate_child(__MODULE__, pid) end).()
  end
end

