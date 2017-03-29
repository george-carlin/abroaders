class RemoveAlliances < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :currencies, :alliances

    drop_table "alliances", force: :cascade do |t|
      t.string   "name",       null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer  "order",      null: false
    end

    add_column :currencies, :alliance_name, :string

    Currency.where(alliance_id: 1).update_all(alliance_name: 'OneWorld')
    Currency.where(alliance_id: 2).update_all(alliance_name: 'StarAlliance')
    Currency.where(alliance_id: 3).update_all(alliance_name: 'SkyTeam')
    Currency.where(alliance_id: 4).update_all(alliance_name: 'Independent')

    change_column_null :currencies, :alliance_name, false
    change_column_null :currencies, :alliance_id,   true

    # currencies.alliance_id can be removed in a later commit
  end
end
