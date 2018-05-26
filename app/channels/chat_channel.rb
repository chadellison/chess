class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:game_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    ChatMessage.create(content: opts.fetch('content'), game_id: opts.fetch('game_id'))
  end
end
