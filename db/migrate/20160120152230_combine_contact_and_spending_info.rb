class CombineContactAndSpendingInfo < ActiveRecord::Migration[5.0]
  def change
    drop_table :spending_infos

    change_table :contact_infos do |t|
      t.integer  :citizenship,                default: 0,     null: false
      t.integer  :credit_score,                               null: false
      t.boolean  :will_apply_for_loan,        default: false, null: false
      t.integer  :spending_per_month_dollars, default: 0,     null: false
      t.integer  :has_business,               default: 0,     null: false
    end

    rename_table :contact_infos, :user_infos
  end
end
