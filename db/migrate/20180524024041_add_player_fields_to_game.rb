class AddPlayerFieldsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :white_player, :integer
    add_column :games, :black_player, :integer
    add_index :users, :token
  end
end
