module Api
  module V1
    class AllGamesController < ApplicationController
      def index
        games = Game.handle_game_observations
        game_data = games.map { |game| GameSerializer.serialize(game) }
        render json: { data: game_data }
      end

      def show
        game = Game.find(params[:id])
        render json: { data: GameSerializer.serialize(game) }
      end
    end
  end
end
