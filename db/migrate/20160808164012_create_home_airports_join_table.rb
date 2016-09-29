class CreateHomeAirportsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts_home_airports do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :airport, null: false, foreign_key: { to_table: :destinations, on_delete: :restrict }

      t.index [:account_id, :airport_id], unique: true

      t.timestamps
    end
  end
end
