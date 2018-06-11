class AddIndexToMoveValue < ActiveRecord::Migration[5.2]
  def change
    add_index :moves, :value
  end
end
