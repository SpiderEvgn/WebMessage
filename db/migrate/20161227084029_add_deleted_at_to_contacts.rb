class AddDeletedAtToContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :deleted_at, :datetime
  end
end
