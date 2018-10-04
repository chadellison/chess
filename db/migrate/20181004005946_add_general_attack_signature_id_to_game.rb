class AddGeneralAttackSignatureIdToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :general_attack_signature_id, :integer
  end
end
