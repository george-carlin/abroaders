class CreateDestinations < ActiveRecord::Migration[5.0]
  def change
    create_table :destinations do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :type, null: false
      t.integer :parent_id
      t.integer :children_count, null: false, default: 0

      t.timestamps
    end
    add_index :destinations, :name
    add_index :destinations, :code, unique: true
    add_index :destinations, :type
    add_index :destinations, :parent_id
  end
end
