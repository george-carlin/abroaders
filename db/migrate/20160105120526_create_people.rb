class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.integer :user_id,    null: false
      t.string  :first_name, null: false

      t.index [:user_id, :main], unique: true
      t.foreign_key :users, on_delete: :cascade

      t.timestamps

      t.boolean :main, null: false, default: true
    end

    add_column :card_accounts, :person_id, :integer, null: false
    add_foreign_key :card_accounts, :people, on_delete: :cascade
  end
end
