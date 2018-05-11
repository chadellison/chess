class RemoveGameSetups < ActiveRecord::Migration[5.2]
  def change
    drop_table :game_setups
  end
end
