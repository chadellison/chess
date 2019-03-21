class AddOutcomesToSignatures < ActiveRecord::Migration[5.2]
  def change
    add_column :signatures, :outcomes, :text
  end
end
