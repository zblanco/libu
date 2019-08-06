defmodule Libu.Chat.Persistence do
  @moduledoc """
  Builds ETS projections of chat data we care about.
  """
  alias Libu.Chat.Events.{ConversationStarted, MessageAddedToConversation}
  def prepare_conversation(%ConversationStarted{} = _convo_started) do
    # Initiate a transient genserver that for a given conversation caches the conversation in ets
    :ok
  end

  def add_to_conversation(%MessageAddedToConversation{} = _convo_added_to) do
    # If it doesn't exist already, restart the conversation cache process
    :ok
  end
end
