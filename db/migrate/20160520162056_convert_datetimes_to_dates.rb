class ConvertDatetimesToDates < ActiveRecord::Migration[5.0]
  def up
    # change them from datetimes to dates:
    change_column :card_accounts, :recommended_at, :date
    change_column :card_accounts, :applied_at,     :date
    change_column :card_accounts, :opened_at,      :date
    change_column :card_accounts, :earned_at,      :date
    change_column :card_accounts, :closed_at,      :date
    change_column :card_accounts, :clicked_at,     :date
    change_column :card_accounts, :declined_at,    :date
  end

  def down
    change_column :card_accounts, :recommended_at, :datetime
    change_column :card_accounts, :applied_at,     :datetime
    change_column :card_accounts, :opened_at,      :datetime
    change_column :card_accounts, :earned_at,      :datetime
    change_column :card_accounts, :closed_at,      :datetime
    change_column :card_accounts, :clicked_at,     :datetime
    change_column :card_accounts, :declined_at,    :datetime
  end
end
