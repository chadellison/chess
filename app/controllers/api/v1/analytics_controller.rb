module Api
  module V1
    class AnalyticsController < ApplicationController
      before_action :find_analytics

      def index
        render json: @analytics.win_ratio
      end

      def create
        render json: @analytics.next_move_analytics(login_params[:moves])
      end

      private

      def find_analytics
        @analytics = Analytics.new(
          Setup.find_or_create_by(position_signature: login_params[:signature])
        )
      end

      def login_params
        params.permit(:signature, moves: [:value, :move_count])
      end
    end
  end
end
