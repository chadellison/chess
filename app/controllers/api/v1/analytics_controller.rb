module Api
  module V1
    class AnalyticsController < ApplicationController
      def index
        setup = setup = Setup.find_by(position_signature: params[:setup])
        render json: AnalyticsSerializer.serialize(setup)
      end
    end

    def login_params
      params.permit(:setup)
    end
  end
end
