class OverhaulCardAccountStatus < ActiveRecord::Migration[5.0]
  def change
    # CardAccount.status is undergoing a massive overhaul

    # First of all, it's no longer a database column:
    remove_column :card_accounts, :status, :integer, null: false

    # Instead, it's determined programatically from the timestamp columns - and
    # we need some new timestamp columns:
    add_column :card_accounts, :denied_at, :date
    add_column :card_accounts, :nudged_at, :date
    add_column :card_accounts, :called_at, :date
    add_column :card_accounts, :redenied_at, :date

    # Finally, we can get rid of 'reconsidered' too, as it's no longer relevant
    remove_column :card_accounts, :reconsidered, :boolean, default: false, null: false
  end
end
