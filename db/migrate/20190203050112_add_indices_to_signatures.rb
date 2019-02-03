class AddIndicesToSignatures < ActiveRecord::Migration[5.2]
  def change
    add_index :setups, :general_attack_signature_id
    add_index :setups, :white_threat_signature_id
    add_index :setups, :black_threat_signature_id
    add_index :setups, :white_attack_signature_id
    add_index :setups, :black_attack_signature_id
    add_index :setups, :material_signature_id
  end
end
