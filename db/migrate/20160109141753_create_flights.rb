class CreateFlights < ActiveRecord::Migration[5.0]
  def change
    create_table :flights do |t|
      t.references :travel_plan, index: true, null: false
      t.integer    :position, null: false, default: 0, limit: 2
      t.references :from, index: true, null: false
      t.references :to,   index: true, null: false

      t.index [:travel_plan_id, :position], unique: true

      t.timestamps
    end

    add_foreign_key :flights, :travel_plans,                   on_delete: :cascade
    add_foreign_key :flights, :destinations, column: :from_id, on_delete: :restrict
    add_foreign_key :flights, :destinations, column: :to_id,   on_delete: :restrict

  end
end
