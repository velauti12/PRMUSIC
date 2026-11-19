class Artist < ApplicationRecord
  # Los artistas que propone un usuario al subir una canción quedan pendientes
  # hasta que un admin los revisa.
  enum :status, { pending: 0, approved: 1 }, default: :approved

  belongs_to :user, optional: true # quién lo propuso
  has_many :albums, dependent: :destroy
  has_many :songs, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2, maximum: 100 }
  validates :bio, length: { maximum: 1000, too_long: "es demasiado extensa (máximo %{count} caracteres)" }

  def self.find_by_name(name)
    find_by("LOWER(name) = ?", name.to_s.strip.downcase)
  end

  # Pasa las canciones y álbumes de este artista a `target` y lo borra.
  # Sirve cuando alguien propuso un artista que ya existía con otro nombre.
  def merge_into!(target)
    transaction do
      songs.update_all(artist_id: target.id)
      albums.update_all(artist_id: target.id)
      reload.destroy!
    end
  end
end
