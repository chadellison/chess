class AddWpaAttackSignatureIdToSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :wpa_signature_id, :integer
    add_index :setups, :wpa_signature_id
  end
end
