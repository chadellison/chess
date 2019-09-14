module Api
  module V1
    class GamesController < ApplicationController
      before_action :authenticate_with_token

      def index
        game_data = Game.user_games(@user.id).order(created_at: :desc)
                        .map { |game| GameSerializer.serialize(game) }

        render json: { data: game_data }
      end

      def create
        user_game_logic = UserGameLogic.new
        game = user_game_logic.create_user_game(@user, game_params)
        render json: { data: GameSerializer.serialize(game) }
      end

      def join_game
        games = Game.find_open_games(@user.id)

        if games.present?
          game = games.first
          game.join_user_to_game(@user.id)
          render json: { data: GameSerializer.serialize(game) }
        else
          render json: { data: {} }
        end
      end

      def machine_vs_machine
        game = Game.create
        MachineVsMachineJob.perform_later(game)
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
