class CreateAbstractions < ActiveRecord::Migration[5.2]
  def change
    create_table :abstractions do |t|
      t.text :pattern
      t.timestamps
    end
    add_column :setups, :abstraction_id, :integer
  end
end
