class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:game_id]}"
  end

  def unsubscribed
  end

  def create(opts)
    game_id = opts.fetch('game_id')
    chat_message = opts.fetch('content')
    ChatMessageEventBroadcastJob.perform_later(game_id, chat_message)
  end
end
