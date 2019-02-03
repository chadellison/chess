class AddSignatureIdsToSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :white_threat_signature_id, :integer
    add_column :setups, :black_threat_signature_id, :integer
    drop_table :threat_signatures
  end
end
