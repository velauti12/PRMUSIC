class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :songs, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :bio, length: { maximum: 1000, too_long: "es demasiado extensa (máximo %{count} caracteres)" }
end
