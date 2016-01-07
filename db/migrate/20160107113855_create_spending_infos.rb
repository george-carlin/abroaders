class CreateSpendingInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :spending_infos do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.integer :citizenship, null: false, default: 0
      t.integer :credit_score, null: false
      t.boolean :will_apply_for_loan, null: false, default: false
      t.integer :spending_per_month_dollars, null: false, default: 0
      t.integer :has_business, null: false, default: 0

      t.timestamps
    end
  end
end
