defmodule Libu.Chat.ConversationSession do
  @moduledoc """
  Maintains state about what a user is doing within a given conversation.

  ## State we want to keep:

  * Which conversation id they're viewing
  * Which messages they're looking at currently (start and end indexes)
  * Whether or not they're currently typing
  * The current text being edited prior to submission

  ## How we implement this:

  * Dynamically Supervised and started when a `/chat/:conversation_id` route is accessed
  * Receive messages from the Liveview about what the user is doing (we may need JS client-side to get scroll state)
  * Handle "start typing" message
  * Add To Conversation (Submit)
  * Scroll State is communicated to the Conversation Projector processes so it can cache/stream as needed

  ## TODO:

  * Integrate with LiveView
  * Get Message Editing worked out (either start an analysis session or control the )
  * Publish a ConversationAttendeeAdded event so we can build a conversation attendee projection
  * Initiate a Text Analysis session while editing messages (lower priority)
  """
  use GenServer

  alias Libu.Chat.{Query}

  def via({user_id, conversation_id}) when is_binary(user_id) and is_binary(conversation_id) do
    {:via, Registry, {Libu.Chat.ConversationSessionRegistry, {user_id, conversation_id}}}
  end

  def child_spec({user_id, conversation_id}) do
    %{
      id: {__MODULE__, {user_id, conversation_id}},
      start: {__MODULE__, :start_link, [{user_id, conversation_id}]},
      restart: :temporary,
    }
  end

  def start_link({user_id, conversation_id}) do
    GenServer.start_link(
      __MODULE__,
      {user_id, conversation_id},
      name: via({user_id, conversation_id})
    )
  end

  def start(user_id, conversation_id) do
    DynamicSupervisor.start_child(
      Libu.Chat.ConversationSessionSupervisor,
      {__MODULE__, {user_id, conversation_id}}
    )
  end

  def init({user_id, conversation_id}) do
    {:ok, %{
      user_id: user_id,
      conversation_id: conversation_id,
      start_index: 0,
      end_index: 15, # we may need to pass in indexes to start the session for varying client-side screen sizes
      current_message_body: nil,
    }}
  end

  def edit_message_to_publish({_user_id, _convo_id} = session_identifier, current_msg_body) do
    GenServer.call(via(session_identifier), {:edit_message_to_publish, current_msg_body})
  end

  def change_scroll_state({_user_id, _convo_id} = session_identifier, start_index, end_index) do
    GenServer.call(via(session_identifier), {:change_scroll_state, start_index, end_index})
  end

  def add_to_conversation({_user_id, _convo_id} = session_identifier, message_body) do
    GenServer.call(via(session_identifier), {:add_to_conversation, message_body})
  end

  def handle_call({:change_scroll_state, start_index, end_index}, _from, session_state) do
    %{start_index: _previous_start_index, end_index: _previous_end_index} = session_state

    new_session_state = %{session_state |
      start_index: start_index,
      end_index: end_index
    }
    Query.stream_conversation(start_index, end_index) # async notify of query stream request to conversation projection to re-cache convo msgs if necessary
    # Should result in pubsub `conversation_stream_query_ready` message allowing Liveview to fetch
    {:reply, :ok, new_session_state}
  end

  def handle_call({:add_to_conversation, msg_body}, _from, session_state) do
    %{
      current_message_body: _current_msg_body,
      user_id: user_id,
      conversation_id: conversation_id,
    } = session_state

    new_session_state = %{session_state | current_message_body: nil}

    Libu.Chat.add_to_conversation(%{
      conversation_id: conversation_id,
      publisher_id: user_id,
      message: msg_body
    })
    {:reply, :ok, new_session_state}
  end

  # def handle_call({:edit_message_to_publish, new_msg_body}, _from, session_state) do
  #   %{
  #     current_message_body: nil,
  #     user_id: user_id,
  #     conversation_id: convo_id,
  #   } = session_state

  #   new_session_state = %{session_state | current_message_body: new_msg_body}
  #   event = MessageBeingEditedForConversation.new(new_session_state)
  #   {:reply, :ok, new_session_state}
  # end

  # def handle_call({:edit_message_to_publish, new_msg_body}, _from, session_state) do
  #   %{
  #     current_message_body: prior_msg_body,
  #     user_id: user_id,
  #     conversation_id: convo_id,
  #   } = session_state

  #   new_session_state = %{session_state | current_message_body: new_msg_body}
  #   event = MessageBeingEditedForConversation.new(new_session_state)
  #   {:reply, :ok, new_session_state}
  # end
end
