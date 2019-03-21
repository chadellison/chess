class RemoveRankFromSignature < ActiveRecord::Migration[5.2]
  def change
    remove_column :signatures, :rank
  end
end
