class AddStatusToGame < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :active
    add_column :games, :status, :string
  end
end
