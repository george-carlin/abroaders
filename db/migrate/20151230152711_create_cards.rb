class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string  :identifier, null: false
      t.string  :name, null: false
      t.integer :brand, null: false
      t.integer :bp, null: false
      t.string  :type, null: false
      t.integer :annual_fee_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :cards, :identifier, unique: true
  end
end
