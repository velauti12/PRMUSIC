class ConvertSongsAlbumToReference < ActiveRecord::Migration[8.1]
  def up
    add_reference :songs, :album, foreign_key: true

    # Migrate data
    Song.reset_column_information
    Song.find_each do |song|
      if song.read_attribute(:album).present?
        album = Album.find_or_create_by!(title: song.read_attribute(:album), artist_id: song.artist_id)
        song.update_column(:album_id, album.id)
      end
    end

    remove_column :songs, :album
  end

  def down
    add_column :songs, :album, :string

    # Reverse migrate data
    Song.reset_column_information
    Song.find_each do |song|
      if song.album_id.present?
        album = Album.find(song.album_id)
        song.update_column(:album, album.title)
      end
    end

    remove_reference :songs, :album, foreign_key: true
  end
end
