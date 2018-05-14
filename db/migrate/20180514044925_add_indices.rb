class AddIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :pieces, :game_id
    add_index :moves, :game_id
    add_index :moves, :setup_id
  end
end
