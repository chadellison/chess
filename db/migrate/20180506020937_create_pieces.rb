class CreatePieces < ActiveRecord::Migration[5.2]
  def change
    create_table :pieces do |t|
      t.string :position
      t.integer :position_index
      t.string :color
      t.string :piece_type
      t.boolean :moved_two, default: false
      t.boolean :has_moved, default: false
      t.integer :game_id
      t.timestamps
    end
  end
end
