class RefactorSpending < ActiveRecord::Migration[5.0]
  def change
    # Requirements change: now spending will *always* be shared, so these two
    # columns are redundant:
    remove_column :accounts, :shares_expenses, :boolean, default: false, null: false
    remove_column :spending_infos, :personal_spending, :integer, default: 0, null: false

    add_column :accounts, :monthly_spending_usd, :integer

    # The 'Person' model (previously 'Passenger') has been reduced in scope,
    # and not every Person will be applying for cards (i.e. will need to
    # add SpendingInfo). Since citizenship is only relevant if they're going
    # to apply for cards, it belongs in spending_infos, not people:
    remove_column :people, :citizenship, :integer, default: 0, null: false
    # At the time of writing there are no 'real' People or SpendingInfos
    # in any DB, so we don't need to worry about preserving any data
    add_column :spending_infos, :citizenship, :integer, default: 0, null: false

    rename_column :spending_infos, :business_spending, :business_spending_usd

    reversible do |d|
      d.up do
        change_column :spending_infos, :business_spending_usd, :integer, default: nil, null: true
      end
      d.down do
        change_column :spending_infos, :business_spending_usd, :integer, default: 0, null: false
      end
    end

    remove_column :people, :willing_to_apply, :boolean, default: true, null: false
  end
end
