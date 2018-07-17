class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "group_chat"
  end

  def unsubscribed
  end

  def create(opts)
    GroupChat.create(content: opts.fetch('content'))
  end
end
