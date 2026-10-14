class UserMailer < ApplicationMailer
  default from: "no-reply@prmusic.com"

  def welcome_email
    @user = params[:user]
    @url  = "http://localhost:3000/login"
    mail(to: @user.email, subject: "¡Bienvenido a PRMUSIC!")
  end
end
