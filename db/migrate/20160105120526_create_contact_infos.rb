class CreateContactInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_infos do |t|
      t.integer :user_id, null: false, index: :unique
      t.string :first_name, null: false
      t.string :middle_names
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.boolean :text_message, null: false, default: false
      t.boolean :whatsapp, null: false, default: false
      t.boolean :imessage, null: false, default: false

      t.timestamps
    end

    remove_column :users, :name, :string, null: false

    add_foreign_key :contact_infos, :users, on_delete: :cascade
  end
end
