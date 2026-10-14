class Song < ApplicationRecord
  belongs_to :artist
  belongs_to :genre, optional: true
  belongs_to :album, optional: true
  belongs_to :user, optional: true
  has_many :favorites, dependent: :destroy

  attribute :status, :integer, default: 0
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending
  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :content, presence: true, length: { minimum: 10, message: "debe tener al menos 10 caracteres" }
  validates :original_key, presence: true, length: { maximum: 5 }, format: { with: /\A[A-G][b#]?(m|min|maj|dim|aug)?(7|9|11|13)?\z/i, message: "debe ser un acorde válido (ej: G, Am, C#, F#m7)" }

  scope :search, ->(query) {
    if query.present?
      joins(:artist).where("LOWER(songs.title) LIKE :q OR LOWER(artists.name) LIKE :q", q: "%#{query.downcase}%")
    end
  }

  def transposed_content(semitones)
    SongTransposer.call(content, original_key, semitones)
  end
end
