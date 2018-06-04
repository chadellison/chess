module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        render json: AnalyticsSerializer.serialize(params[:notation])
      end
    end
  end
end
