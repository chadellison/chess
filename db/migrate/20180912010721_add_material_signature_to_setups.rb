class AddMaterialSignatureToSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :setups, :material_signature_id, :integer
  end
end
