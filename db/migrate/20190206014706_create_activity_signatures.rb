class CreateActivitySignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_signatures do |t|
      t.string :signature, index: true
      t.integer :rank, default: 0
      t.timestamps
    end

    add_column :setups, :activity_signature_id, :integer
    add_index :setups, :activity_signature_id
  end
end
