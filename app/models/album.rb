class Album < ApplicationRecord
  belongs_to :artist
  has_many :songs, dependent: :nullify
  has_one_attached :cover

  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validate :cover_must_be_an_image

  COVER_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  COVER_MAX_SIZE = 5.megabytes

  private

  def cover_must_be_an_image
    return unless cover.attached?

    errors.add(:cover, "debe ser una imagen PNG, JPG o WEBP") unless cover.content_type.in?(COVER_CONTENT_TYPES)
    errors.add(:cover, "no puede pesar más de 5 MB") if cover.byte_size > COVER_MAX_SIZE
  end
end
