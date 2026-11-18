class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token

  private

  # Devuelve el usuario dueño del token "Authorization: Bearer <token>", o nil.
  def current_user_from_token
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil if token.blank?

    User.find_by(token: token)
  end

  def authenticate_token!
    @current_user = current_user_from_token

    unless @current_user
      render json: { error: "No autorizado. Token inválido o faltante." }, status: :unauthorized
    end
  end

  def authenticate_admin_token!
    authenticate_token!
    if @current_user && @current_user.role != "admin"
      render json: { error: "No autorizado. Se requieren permisos de administrador." }, status: :forbidden
    end
  end

  rescue_from Exception do |e|
    puts "\n--- EXCEPTION ---"
    puts "#{e.class}: #{e.message}"
    puts e.backtrace.join("\n")
    puts "-----------------\n"
    raise e
  end
end
