module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        user = User.find_by(username: params[:username])

        if user&.authenticate(params[:password])
          user.regenerate_token # Generates a new token on each login for security
          render json: { token: user.token, user_id: user.id, role: user.role }, status: :ok
        else
          render json: { error: "Credenciales inválidas" }, status: :unauthorized
        end
      end
    end
  end
end
