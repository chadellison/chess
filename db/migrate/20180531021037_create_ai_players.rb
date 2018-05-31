class CreateAiPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :ai_players do |t|
      t.string :color
      t.string :name
      t.timestamps
    end
  end
end
