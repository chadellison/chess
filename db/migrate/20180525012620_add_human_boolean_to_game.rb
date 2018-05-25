class AddHumanBooleanToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :human, :boolean, default: false
  end
end
