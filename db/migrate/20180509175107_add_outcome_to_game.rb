class AddOutcomeToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :outcome, :integer, default: 0
  end
end
