class AddOnboardedHomeAirportsToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarded_home_airports, :boolean, default: false, null: false
  end
end
