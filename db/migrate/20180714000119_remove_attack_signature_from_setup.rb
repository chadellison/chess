class RemoveAttackSignatureFromSetup < ActiveRecord::Migration[5.2]
  def change
    remove_column :setups, :attack_signature, :string
  end
end
