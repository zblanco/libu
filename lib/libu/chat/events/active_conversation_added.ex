defmodule Libu.Chat.Events.ActiveConversationAdded do
  @moduledoc """
  Notifies our UI of read-model readiness.
  """
  alias Libu.Chat.Events.ConversationStarted
  defstruct [
    :conversation_id,
    :initiated_by,
    :initiated_by_id,
    :initial_message,
  ]
  def new(%ConversationStarted{} = started) do
    params = Map.from_struct(started)
    struct(__MODULE__, params)
  end
end
