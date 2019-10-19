class AllGamesEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game)
    ActionCable
      .server
      .broadcast('all_games', GameSerializer.serialize(game))
  end
end
