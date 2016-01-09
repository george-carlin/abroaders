class CreateTravelPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_plans do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
