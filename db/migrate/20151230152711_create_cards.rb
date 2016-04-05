class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string  :identifier, null: false, index: { unique: true }
      t.string  :name, null: false
      t.integer :brand, null: false
      t.integer :bp, null: false
      t.integer :bank, null: false
      t.integer :type, null: false
      t.integer :annual_fee_cents, null: false
      t.boolean :active, null: false, default: true
      t.integer :currency_id, null: false, index: true

      t.foreign_key :currencies, on_delete: :restrict

      t.timestamps
    end
  end
end
