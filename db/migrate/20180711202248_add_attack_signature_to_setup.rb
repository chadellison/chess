class AddAttackSignatureToSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :attack_signature, :string, index: true
  end
end
