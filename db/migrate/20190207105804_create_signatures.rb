class CreateSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :signatures do |t|
      t.string :value, index: true
      t.integer :rank, default: 0
      t.string :signature_type
      t.timestamps
    end
  end
end
