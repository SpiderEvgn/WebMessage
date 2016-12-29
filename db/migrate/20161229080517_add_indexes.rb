class AddIndexes < ActiveRecord::Migration[5.0]
  def change
  	add_index :contacts, :contact_id
  	add_index :contacts, :deleted_at
  	add_index :messages, :to_user_id
  	add_index :messages, :created_at
  	add_index :messages, :is_read
  	add_index :users, :username
  end
end
