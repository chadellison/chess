class AddIndexToPositionSignature < ActiveRecord::Migration[5.2]
  def change
    add_index :setups, :position_signature
  end
end
