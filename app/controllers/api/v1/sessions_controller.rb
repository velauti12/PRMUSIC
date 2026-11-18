module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_token!, only: :destroy

      # POST /api/v1/login  { "username": "...", "password": "..." }
      def create
        user = User.find_by(username: params[:username])

        if user&.authenticate(params[:password])
          user.regenerate_token # Genera un token nuevo en cada login
          render json: { token: user.token, user_id: user.id, username: user.username, role: user.role }, status: :ok
        else
          render json: { error: "Credenciales inválidas" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout — invalida el token actual
      def destroy
        @current_user.regenerate_token
        head :no_content
      end
    end
  end
end
