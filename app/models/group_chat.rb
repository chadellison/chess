class GroupChat < ApplicationRecord
  after_create_commit do
    GroupChatCreationEventBroadcastJob.perform_later(self)
  end
end
