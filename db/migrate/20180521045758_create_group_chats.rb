class CreateGroupChats < ActiveRecord::Migration[5.2]
  def change
    create_table :group_chats do |t|
      t.text :content
      t.timestamps
    end
  end
end
