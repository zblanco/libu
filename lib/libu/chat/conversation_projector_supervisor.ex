# defmodule Libu.Chat.ConversationProjectorSupervisor do
#   use DynamicSupervisor

#   alias Libu.Chat.ConversationProjector

#   def start_link() do

#   end

#   def start_conversation_projector(convo_id) do
#     DynamicSupervisor.start_child(
#       __MODULE__,
#       {ConversationProjector, convo_id}
#     )
#   end

#   def stop_conversation_projector(convo_id) do

#   end
# end
