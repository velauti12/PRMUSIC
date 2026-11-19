class UserMailer < ApplicationMailer
  # Con Gmail el remitente tiene que ser la misma cuenta que manda
  default from: -> {
    ENV["MAIL_FROM"].presence ||
      (ENV["SMTP_USERNAME"].present? ? "PRMUSIC <#{ENV["SMTP_USERNAME"]}>" : "PRMUSIC <no-reply@prmusic.com>")
  }

  def welcome_email
    @user = params[:user]
    # El login está en el front, no en la API
    @url  = "#{ENV.fetch("FRONTEND_URL", "http://localhost:5173").split(",").first.strip}/login"
    mail(to: @user.email, subject: "¡Bienvenido a PRMUSIC!")
  end
end
