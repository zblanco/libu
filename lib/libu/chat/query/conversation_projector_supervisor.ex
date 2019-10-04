defmodule Libu.Chat.ConversationProjectorSupervisor do
  use DynamicSupervisor

  alias Libu.Chat.ConversationProjector

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], __MODULE__)
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

  def stop_conversation_projector(convo_id) do
    convo_id
    |> ConversationProjector.via()
    |> GenServer.whereis()
    |> (fn pid -> DynamicSupervisor.terminate_child(__MODULE__, pid) end).()
  end
end

