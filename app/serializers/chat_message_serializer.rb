class ChatMessageSerializer
  class << self
    def serialize(chat_message)
      { content: chat_message }
    end
  end
end
