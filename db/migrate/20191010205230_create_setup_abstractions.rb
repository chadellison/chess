class CreateSetupAbstractions < ActiveRecord::Migration[6.0]
  def change
    create_table :setup_abstractions do |t|
      t.integer :setup_id
      t.integer :abstraction_id
      t.timestamps
    end
  end
end
