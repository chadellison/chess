class AddThreatSignatureToSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :threat_signature_id, :integer
  end
end
