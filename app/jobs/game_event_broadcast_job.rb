class GameEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game)
    ActionCable
      .server
      .broadcast("game_#{game.id}", GameSerializer.serialize(game))
  end
end
