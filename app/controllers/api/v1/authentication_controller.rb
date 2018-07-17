module Api
  module V1
    class AuthenticationController < ApplicationController
      def create
        user = User.find_by(email: login_params[:email].downcase)
        if user.present? && user.authenticate(login_params[:password])
          user.update(token: SecureRandom.hex)
          render json: UserSerializer.serialize(user), status: 201
        else
          render json: { errors: "Invalid Credentials" }, status: 404
        end
      end

      private

      def login_params
        params.require(:credentials).permit(:email, :password)
      end
    end
  end
end
