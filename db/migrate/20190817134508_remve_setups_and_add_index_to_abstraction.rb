class RemveSetupsAndAddIndexToAbstraction < ActiveRecord::Migration[5.2]
  def change
    add_index :abstractions, :pattern
    drop_table :signatures
    drop_table :setup_signatures
  end
end
