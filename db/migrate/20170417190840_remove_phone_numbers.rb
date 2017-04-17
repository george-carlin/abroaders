class RemovePhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :phone_number, :string
    add_column :accounts, :phone_number_normalized, :string
    add_index :accounts, :phone_number_normalized

    reversible do |d|
      d.up do
        ApplicationRecord.connection.execute('select * from phone_numbers').to_a.each do |row|
          Account.find(row['account_id']).update!(
            phone_number: row['number'],
            phone_number_normalized: row['normalized_number'],
          )
        end
      end
    end

    drop_table "phone_numbers" do |t|
      t.integer  "account_id",        null: false
      t.string   "number",            null: false
      t.string   "normalized_number", null: false
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
      t.index ["account_id"], name: "index_phone_numbers_on_account_id", using: :btree
      t.index ["normalized_number"], name: "index_phone_numbers_on_normalized_number", using: :btree
    end
  end
end
