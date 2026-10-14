class AddAlbumToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :album, :string
  end
end
