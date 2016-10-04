class CreateJoinTableAccountsRegions < ActiveRecord::Migration[5.0]
  def change
    create_table :interest_regions do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :region, null: false, foreign_key: { to_table: :destinations, on_delete: :restrict }

      t.index [:account_id, :region_id], unique: true

      t.timestamps
    end
  end
end
