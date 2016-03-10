class RenameSurveysToPassengers < ActiveRecord::Migration[5.0]
  def change
    rename_table :surveys, :passengers
    add_column :passengers, :main, :boolean, null: false, default: true
    # There are two types of passengers: 'main' and 'companion'. An account
    # will always have one main passenger, and optionally one companion
    # passenger.
    add_index :passengers, [:account_id, :main], unique: true
  end
end
