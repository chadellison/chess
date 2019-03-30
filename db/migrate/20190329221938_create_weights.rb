class CreateWeights < ActiveRecord::Migration[5.2]
  def change
    create_table :weights do |t|
      t.string :weight_type
      t.string :value
      t.string :win_value
      t.timestamps
    end
  end
end
