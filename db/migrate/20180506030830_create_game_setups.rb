class CreateGameSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :game_setups do |t|
      t.integer :game_id
      t.integer :setup_id
      t.timestamps
    end
  end
end
