module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        render json: Analytics.analyze_position(analytics_params[:notation])
      end

      private

      def analytics_params
        params.permit(:notation)
      end
    end
  end
end
