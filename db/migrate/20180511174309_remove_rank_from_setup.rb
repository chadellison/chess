class RemoveRankFromSetup < ActiveRecord::Migration[5.2]
  def change
    remove_column :setups, :rank
  end
end
