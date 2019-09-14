class RemoveMaterialValueFromMove < ActiveRecord::Migration[5.2]
  def change
    remove_column :moves, :material_value
    add_column :moves, :checkmate, :boolean
  end
end
