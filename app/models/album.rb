class Album < ApplicationRecord
  belongs_to :artist
  has_many :songs, dependent: :nullify
  has_one_attached :cover

  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
end
