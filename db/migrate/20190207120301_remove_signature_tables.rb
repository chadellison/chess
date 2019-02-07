class RemoveSignatureTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :wra_signatures
    drop_table :wqa_signatures
    drop_table :wpa_signatures
    drop_table :wna_signatures
    drop_table :wka_signatures
    drop_table :white_threat_signatures
    drop_table :wba_signatures
    drop_table :bra_signatures
    drop_table :bqa_signatures
    drop_table :bpa_signatures
    drop_table :bna_signatures
    drop_table :bka_signatures
    drop_table :black_threat_signatures
    drop_table :bba_signatures
    drop_table :material_signatures
    drop_table :activity_signatures

    remove_column :setups, :wra_signature_id
    remove_column :setups, :wqa_signature_id
    remove_column :setups, :wpa_signature_id
    remove_column :setups, :wna_signature_id
    remove_column :setups, :wka_signature_id
    remove_column :setups, :white_threat_signature_id
    remove_column :setups, :wba_signature_id
    remove_column :setups, :bra_signature_id
    remove_column :setups, :bqa_signature_id
    remove_column :setups, :bpa_signature_id
    remove_column :setups, :bna_signature_id
    remove_column :setups, :bka_signature_id
    remove_column :setups, :black_threat_signature_id
    remove_column :setups, :bba_signature_id
    remove_column :setups, :material_signature_id
    remove_column :setups, :activity_signature_id
    remove_column :setups, :attack_signature_id
    remove_column :setups, :threat_signature_id
  end
end
