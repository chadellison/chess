class DropGeneralAttackSignatures < ActiveRecord::Migration[5.2]
  def change
    drop_table :white_attack_signatures
    drop_table :black_attack_signatures
    drop_table :general_attack_signatures
    remove_column :setups, :black_attack_signature_id
    remove_column :setups, :white_attack_signature_id
    remove_column :setups, :general_attack_signature_id
  end
end
