class CreateSetupSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :setup_signatures do |t|
      t.integer :setup_id, index: true
      t.integer :signature_id, index: true
      t.timestamps
    end
  end
end
