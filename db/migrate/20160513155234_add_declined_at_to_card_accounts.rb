class AddDeclinedAtToCardAccounts < ActiveRecord::Migration[5.0]
  def up
    add_column :card_accounts, :declined_at, :datetime

    # At the time this migration runs in production the only cards for which
    # 'applied_at' will be present are cards which have been declined (with the
    # timestamp saved in applied_at as per the old way of doing things)
    CardAccount.find_each do |ca|
      ca.update_attributes!(
        applied_at: nil,
        declined_at: ca.applied_at,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
