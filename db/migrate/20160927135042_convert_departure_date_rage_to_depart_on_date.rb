class ConvertDepartureDateRageToDepartOnDate < ActiveRecord::Migration[5.0]
  class TravelPlan < ActiveRecord::Base
  end

  def up
    add_column :travel_plans, :depart_on, :date
    add_column :travel_plans, :return_on, :date
    TravelPlan.reset_column_information

    TravelPlan.find_each do |tp|
      tp.update!(depart_on: tp.departure_date_range.first)
    end

    change_column_null :travel_plans, :depart_on, false
    remove_column :travel_plans, :departure_date_range
  end

  def down
    add_column :travel_plans, :departure_date_range, :daterange
    TravelPlan.reset_column_information

    TravelPlan.find_each do |tp|
      tp.update(departure_date_range: tp.depart_on..tp.depart_on)
    end

    change_column_null :travel_plans, :departure_date_range, false
    remove_column :travel_plans, :depart_on
    remove_column :travel_plans, :return_on
  end
end
