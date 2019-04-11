class RemoveOutcomesFromSignatures < ActiveRecord::Migration[5.2]
  def change
    remove_column :signatures, :outcomes, :text
  end
end
