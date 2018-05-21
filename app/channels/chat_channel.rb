class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:game_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    # needs to take a game_id and create that on this chat
    ChatMessage.create(content: opts.fetch('content'))
  end
end
