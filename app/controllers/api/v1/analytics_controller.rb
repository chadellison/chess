module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        signature = JSON.parse(params[:signature])['analytics']['notation']
        render json: AnalyticsSerializer.serialize(signature)
      end
    end
  end
end
