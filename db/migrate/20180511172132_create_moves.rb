class CreateMoves < ActiveRecord::Migration[5.2]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :setup_id
      t.string :value
      t.integer :move_count, default: 0
      t.integer :rank, defalut: 0
      t.timestamps
    end
  end
end
