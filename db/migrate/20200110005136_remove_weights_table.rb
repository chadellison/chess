class RemoveWeightsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :weights
  end
end
