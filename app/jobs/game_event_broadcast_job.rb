class GameEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game_data)
    ActionCable
      .server
      .broadcast("game_#{game_data[:id]}", game_data)
  end
end
