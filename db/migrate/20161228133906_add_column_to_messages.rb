class AddColumnToMessages < ActiveRecord::Migration[5.0]
  def change
  	add_column :messages, :is_read, :boolean, default: false
  end
end
