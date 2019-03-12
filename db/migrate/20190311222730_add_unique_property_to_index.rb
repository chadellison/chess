class AddUniquePropertyToIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :setups, :position_signature
    add_index :setups, :position_signature, unique: true
  end
end
