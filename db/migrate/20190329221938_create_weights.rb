class CreateWeights < ActiveRecord::Migration[5.2]
  def change
    create_table :weights do |t|
      t.integer :weight_count
      t.string :value
      t.timestamps
    end
  end
end
