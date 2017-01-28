class CreateBanks < ActiveRecord::Migration[5.0]
  def change
    create_table :banks do |t|
      t.string  :name, null: false
      t.integer :personal_code, null: false
      t.string  :personal_phone
      t.string  :business_phone

      t.timestamps
    end

    add_foreign_key :cards, :banks
  end
end
