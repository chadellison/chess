module Api
  module V1
    class GamesController < ApplicationController
      def index
        games = Game.active_games
        render json: ActiveGamesSerializer.serialize(games)
      end
    end
  end
end
