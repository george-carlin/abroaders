class CreateTravelPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_plans do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.integer    :type, index: true,    null: false
      t.daterange  :departure_date_range, null: false
      t.integer    :no_of_passengers,     null: false, default: 1

      t.timestamps
    end
  end
end
