class User < ApplicationRecord
  has_secure_password
  has_secure_token :token

  has_many :songs, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_songs, through: :favorites, source: :song

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "solo permite letras, números y guiones bajos" }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "debe ser un correo válido" }

  def admin?
    role == "admin"
  end
end
