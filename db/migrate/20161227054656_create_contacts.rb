class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.references :user, index: true
      t.integer :contact_id

      t.timestamps
    end
  end
end
