class CreatePhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :phone_numbers do |t|
      t.references :account, foreign_key: { on_delete: :cascade }, null: false
      t.string :number, null: false
      t.string :normalized_number, null: false, index: :true

      t.timestamps
    end

    remove_column :accounts, :phone_number, :string
  end
end
