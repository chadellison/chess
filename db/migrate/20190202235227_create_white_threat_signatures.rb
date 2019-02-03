class CreateWhiteThreatSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :white_threat_signatures do |t|
      t.string :signature, index: true
      t.integer :rank, default: 0
      t.timestamps
    end
  end
end
