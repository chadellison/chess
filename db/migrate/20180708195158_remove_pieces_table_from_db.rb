class RemovePiecesTableFromDb < ActiveRecord::Migration[5.2]
  def change
    drop_table :pieces
  end
end
