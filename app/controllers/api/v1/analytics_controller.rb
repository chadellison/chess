module Api
  module V1
    class AnalyticsController < ApplicationController
      def create
        render json: Analytics.new.move_analytics(analytics_params)
      end

      private

      def analytics_params
        params.require(:analytic).permit(
          :turn,
          :notation,
          pieces: [:positionIndex, :pieceType, :color, :position, :movedTwo, :hasMoved],
          moves: [:value, :move_count],
        )
      end
    end
  end
end
