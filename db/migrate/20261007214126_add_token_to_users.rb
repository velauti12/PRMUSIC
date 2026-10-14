class AddTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :token, :string
    add_index :users, :token, unique: true
  end
end
