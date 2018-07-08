class AddPromotedPawnToMove < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :promoted_pawn, :string
  end
end
