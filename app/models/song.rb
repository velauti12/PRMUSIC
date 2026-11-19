class Song < ApplicationRecord
  # Caracteres que aparecen al copiar letras de páginas web y rompen la detección de acordes
  INVISIBLE_CHARS = /\p{Cf}/ # espacios de ancho cero y otros caracteres invisibles
  ODD_SPACES = /\p{Zs}/ # cualquier tipo de espacio (por ej. el espacio duro)

  belongs_to :artist
  belongs_to :genre
  belongs_to :album, optional: true
  belongs_to :user, optional: true
  has_many :favorites, dependent: :destroy

  attribute :status, :integer, default: 0
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending
  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :content, presence: true, length: { minimum: 10, message: "debe tener al menos 10 caracteres" }
  validates :original_key, presence: true, length: { maximum: 5 }, format: { with: /\A[A-G][b#]?(m|min|maj|dim|aug)?(7|9|11|13)?\z/i, message: "debe ser un acorde válido (ej: G, Am, C#, F#m7)" }

  validate :album_must_belong_to_artist
  before_validation :clean_content

  scope :search, ->(query) {
    if query.present?
      joins(:artist).where("LOWER(songs.title) LIKE :q OR LOWER(artists.name) LIKE :q", q: "%#{query.downcase}%")
    end
  }

  def transposed_content(semitones)
    SongTransposer.call(content, original_key, semitones)
  end

  # Tonalidad resultante de transponer la original (ej: "Am" con -2 => "Gm")
  def transposed_key(semitones)
    SongTransposer.call(original_key, original_key, semitones).strip
  end

  private

  # Limpia la letra pegada: saca caracteres invisibles, pasa los espacios raros a
  # espacios comunes, unifica los saltos de línea y borra espacios al final de cada línea
  def clean_content
    return if content.blank?

    self.content = content
      .gsub(/\r\n?/, "\n")
      .gsub(INVISIBLE_CHARS, "")
      .gsub(ODD_SPACES, " ")
      .gsub(/[ \t]+$/, "")
  end

  def album_must_belong_to_artist
    return if album.nil? || artist_id.nil?

    errors.add(:album, "no es de este artista") if album.artist_id != artist_id
  end
end
