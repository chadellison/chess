class CreateManyToManyRelationshipWithAbstractions < ActiveRecord::Migration[6.0]
  def change
    add_column :abstractions, :outcomes, :text
    add_column :abstractions, :abstraction_type, :text
    remove_column :setups, :abstraction_id, :integer
    add_index :abstractions, [:abstraction_type, :pattern], unique: true
  end
end
