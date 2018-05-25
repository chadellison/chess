class AddHumanBooleanToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :game_type, :string, default: 'machine vs machine'
  end
end
