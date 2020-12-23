class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "group_chat"
  end

  def unsubscribed
  end

  def create(opts)
    GroupChatMessageEventBroadcastJob.perform_later(opts.fetch('content'))
  end
end
