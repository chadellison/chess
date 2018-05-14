class AddIndexToNotation < ActiveRecord::Migration[5.2]
  def change
    add_index :games, :notation
  end
end
