module Api
  module V1
    class GamesController < ApplicationController
      before_action :authenticate_with_token

      def index
        games = Game.where(player_one: @user.id)
                    .or(Game.where(player_two: @user.id))
        render json: ActiveGamesSerializer.serialize(games)
      end

      private

      def authenticate_with_token
        @user = User.find_by(token: params[:token])

        raise ActiveRecord::RecordNotFound if @user.blank?
      end
    end
  end
end
