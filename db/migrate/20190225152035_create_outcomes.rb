class CreateOutcomes < ActiveRecord::Migration[5.2]
  def change
    create_table :outcomes do |t|
      t.integer :setup_id
      t.integer :value
      t.index :setup_id
      t.timestamps
    end

    remove_column :setups, :rank
  end
end
