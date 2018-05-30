class Remove < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:games, :outcome, nil)
  end
end
