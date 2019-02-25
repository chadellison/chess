class DropOutcomesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :outcomes
    add_column :setups, :outcomes, :text
  end
end
