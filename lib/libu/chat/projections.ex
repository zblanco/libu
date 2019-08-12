defmodule Libu.Chat.Projections do
  @moduledoc """
  Builds ETS projections of chat data we care about.

  Projection Requirements:

  * Maintain a list of active conversations sortable by their last activity, quantity of messages, and eventually text analysis metrics.
  * Maintain conversation caches that stream messages as needed into ETS keyed by conversation, owned by a single process per conversation
  * Communicate the viewed contexts by a session process similar to Analysis Sessions.
  """
  alias Libu.Chat.Events.{
    ConversationStarted,
    MessageAddedToConversation,
    ConversationEnded,
  }
  def prepare_conversation(%ConversationStarted{} = convo_started) do
    # Initiate a transient genserver that for a given conversation caches the conversation in ets
    # with :ok <- ConversationStreamer.start(convo_started),
    #      :ok <- ConversationTracker.handle_event(convo_started)
    # do
      :ok
    # else
    #   :error
    # end
  end

  def add_to_conversation(%MessageAddedToConversation{} = _convo_added_to) do
    # If it doesn't exist already, restart the conversation cache process
    # the cache process should only include the latest few messages in the conversation that we're adding
    :ok
  end

  def deactivate_conversation(%ConversationEnded{} = _conv_ended) do
    # Let our read model know
    :ok
  end
end
