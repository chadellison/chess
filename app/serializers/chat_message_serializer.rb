class ChatMessageSerializer
  class << self
    def serialize(chat_message)
      {
        id: chat_message.id,
        createdAt: chat_message.created_at.strftime('%H:%M'),
        content: chat_message.content
      }
    end
  end
end
