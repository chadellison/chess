class CreateSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :setups do |t|
      t.text :position_signature
      t.integer :rank, default: 0
      t.timestamps
    end
  end
end
