class GroupChatMessageEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(chat_message)
    ActionCable
      .server
      .broadcast(
        'group_chat',
        { content: chat_message }
      )
  end
end
