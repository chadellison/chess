module Api
  module V1
    class GamesController < ApplicationController
      before_action :authenticate_with_token

      def index
        games = Game.user_games(@user.id)
        render json: { data: games.map { |game| GameSerializer.serialize(game) } }
      end

      def create
        game = Game.create_user_game(@user, game_params)
        render json: { data: GameSerializer.serialize(game) }
      end

      private

      def authenticate_with_token
        @user = User.find_by(token: params[:token])

        raise ActiveRecord::RecordNotFound if @user.blank?
      end

      def game_params
        params.require(:game_data).permit(:game_type, :color)
      end
    end
  end
end
