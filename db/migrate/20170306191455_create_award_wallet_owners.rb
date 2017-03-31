class CreateAwardWalletOwners < ActiveRecord::Migration[5.0]
  def change
    create_table :award_wallet_owners do |t|
      t.references :award_wallet_user, foreign_key: { on_delete: :cascade }, null: false, index: true
      t.string :name, null: false, index: true

      t.references :person, foreign_key: { on_delete: :nullify }, index: true

      t.index [:award_wallet_user_id, :name], unique: true

      t.timestamps null: false
    end
  end
end
