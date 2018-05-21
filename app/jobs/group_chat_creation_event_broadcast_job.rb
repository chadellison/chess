class GroupChatCreationEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(chat_message)
    ActionCable
      .server
      .broadcast(
        'group_chat',
        ChatMessageSerializer.serialize(chat_message)
      )
  end
end
