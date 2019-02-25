module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        setup = setup = Setup.find_by(position_signature: params[:setup])
        analytics = Analytics.new(setup)
        analytics.find_outcomes
        render json: AnalyticsSerializer.serialize(analytics)
      end
    end

    def login_params
      params.permit(:setup)
    end
  end
end
