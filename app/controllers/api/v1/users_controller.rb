module Api
  module V1
    class UsersController < ApplicationController
      def create
        user = User.new(user_params)

        if user.save
          user.update(token: SecureRandom.hex)
          render json: UserSerializer.serialize(user), status: 201
        else
          render json: return_errors(user), status: 400
        end
      end

      private

      def return_errors(resource)
        {
          errors: resource.errors.map do |key, value|
            "#{key} #{value}"
          end.join("\n")
        }
      end

      def user_params
        params.require(:user).permit(:email, :password, :last_name, :first_name)
      end
    end
  end
end
