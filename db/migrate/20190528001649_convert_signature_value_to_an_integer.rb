class ConvertSignatureValueToAnInteger < ActiveRecord::Migration[5.2]
  def change
    change_column :signatures, :value, 'integer USING CAST(value AS integer)'
    remove_column :signatures, :outcomes, :text
  end
end
