class CreateTravelPlanLegs < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_plan_legs do |t|
      t.references :travel_plan, index: true, null: false
      t.references :origin, index: true, null: false
      t.references :destination, index: true, null: false
      t.date :earliest_departure, null: false
      t.date :latest_departure, null: false

      t.timestamps
    end
    add_foreign_key :travel_plan_legs, :travel_plans, on_delete: :cascade
    add_foreign_key :travel_plan_legs, :airports, column: :origin_id
    add_foreign_key :travel_plan_legs, :airports, column: :destination_id
  end
end
