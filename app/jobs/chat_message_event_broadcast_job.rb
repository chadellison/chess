class ChatMessageEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game_id, chat_message)
    ActionCable
      .server
      .broadcast(
        "chat_#{game_id}",
        { content: chat_message }
      )
  end
end
