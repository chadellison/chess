module Api
  module V1
    class GamesController < ApplicationController
      # respond_to :json

      def index
        games = Game.active_games
        render json: ActiveGamesSerializer.serialize(games)
      end
    end
  end
end
