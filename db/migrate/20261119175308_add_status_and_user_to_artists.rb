class AddStatusAndUserToArtists < ActiveRecord::Migration[8.1]
  def change
    # Los artistas que ya existen quedan aprobados (status 1)
    add_column :artists, :status, :integer, default: 1, null: false
    add_reference :artists, :user, null: true, foreign_key: true
  end
end
