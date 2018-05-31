class AddAiPlayerIdToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :ai_player_id, :integer
  end
end
