class UpdateOutcomeToString < ActiveRecord::Migration[5.2]
  def change
    change_column :games, :outcome, :string
  end
end
