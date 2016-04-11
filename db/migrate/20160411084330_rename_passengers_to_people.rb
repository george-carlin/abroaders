class RenamePassengersToPeople < ActiveRecord::Migration[5.0]
  def change
    rename_table :passengers, :people
    rename_column :balances, :passenger_id, :person_id
    rename_column :card_accounts, :passenger_id, :person_id
    rename_column :readiness_statuses, :passenger_id, :person_id
    rename_column :spending_infos, :passenger_id, :person_id
  end
end
