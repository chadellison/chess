class CreateBkaSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :bka_signatures do |t|
      t.string :signature, index: true
      t.integer :rank, default: 0
      t.timestamps
    end

    add_column :setups, :wka_signature_id, :integer
    add_index :setups, :wka_signature_id
    add_column :setups, :bka_signature_id, :integer
    add_index :setups, :bka_signature_id
  end
end
