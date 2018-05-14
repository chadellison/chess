class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:game_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    ChatMessage.create(
      content: opts.fetch('content')
    )
  end
end
