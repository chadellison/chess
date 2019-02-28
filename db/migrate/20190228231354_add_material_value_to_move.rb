class AddMaterialValueToMove < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :material_value, :integer
  end
end
