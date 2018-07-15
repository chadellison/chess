class AddAttackSignatureIdToSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :attack_signature_id, :integer
  end
end
