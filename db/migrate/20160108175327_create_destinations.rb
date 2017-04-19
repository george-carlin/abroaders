class CreateDestinations < ActiveRecord::Migration[5.0]
  def change
    create_table :destinations do |t|
      t.string  :name,           null: false, index: true
      t.string  :code,           null: false
      t.integer :parent_id,                   index: true
      t.integer :children_count, null: false,              default: 0
      t.timestamps
      t.string  :type,           null: false, index: true

      t.index [:code, :type], unique: true
      t.foreign_key :destinations, column: :parent_id, on_delete: :restrict
    end
  end
end
