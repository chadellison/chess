module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        render json: AnalyticsSerializer.serialize(params[:setup])
      end
    end
  end
end
