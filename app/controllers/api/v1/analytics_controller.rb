module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        render json: Analytics.fetch_analytics(params[:signature], params[:type])
      end
    end

    def login_params
      params.permit(:signature, :type)
    end
  end
end
