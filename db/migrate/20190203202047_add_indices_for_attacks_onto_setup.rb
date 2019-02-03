class AddIndicesForAttacksOntoSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :bpa_signature_id, :integer
    add_column :setups, :wna_signature_id, :integer
    add_column :setups, :bna_signature_id, :integer
    add_column :setups, :wba_signature_id, :integer
    add_column :setups, :bba_signature_id, :integer
    add_column :setups, :wra_signature_id, :integer
    add_column :setups, :bra_signature_id, :integer
    add_column :setups, :wqa_signature_id, :integer
    add_column :setups, :bqa_signature_id, :integer 
    add_index :setups, :bpa_signature_id
    add_index :setups, :wna_signature_id
    add_index :setups, :bna_signature_id
    add_index :setups, :wba_signature_id
    add_index :setups, :bba_signature_id
    add_index :setups, :wra_signature_id
    add_index :setups, :bra_signature_id
    add_index :setups, :wqa_signature_id
    add_index :setups, :bqa_signature_id
  end
end
