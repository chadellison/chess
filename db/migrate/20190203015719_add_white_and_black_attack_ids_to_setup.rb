class AddWhiteAndBlackAttackIdsToSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :white_attack_signature_id, :integer
    add_column :setups, :black_attack_signature_id, :integer
    drop_table :attack_signatures
  end
end
