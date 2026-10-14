class Genre < ApplicationRecord
  has_many :songs, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
end
