class AddVideoUrlToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :video_url, :string
  end
end
