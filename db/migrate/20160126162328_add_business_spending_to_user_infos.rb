class AddBusinessSpendingToUserInfos < ActiveRecord::Migration[5.0]
  def change
    add_column :user_infos, :business_spending, :integer, default:0, null:false
    rename_column :user_infos, :spending_per_month_dollars, :personal_spending
  end
end
