class AddPlayerFieldsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :player_one, :integer
    add_column :games, :player_two, :integer
    add_index :users, :token
  end
end
