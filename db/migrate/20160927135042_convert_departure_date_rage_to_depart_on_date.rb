class ConvertDepartureDateRageToDepartOnDate < ActiveRecord::Migration[5.0]
  def change
    add_column :travel_plans, :depart_on, :date, null: false
    add_column :travel_plans, :return_on, :date

    remove_column :travel_plans, :departure_date_range
  end
end
