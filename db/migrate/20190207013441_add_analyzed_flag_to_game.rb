class AddAnalyzedFlagToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :analyzed, :boolean, default: false
  end
end
