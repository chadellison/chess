class AddActiveColumnToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :active, :boolean, default: false
  end
end
