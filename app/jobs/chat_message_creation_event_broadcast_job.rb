class ChatMessageCreationEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(chat_message)
    ActionCable
      .server
      .broadcast(
        "chat_#{1}",
        ChatMessageSerializer.serialize(chat_message)
      )
  end
end
