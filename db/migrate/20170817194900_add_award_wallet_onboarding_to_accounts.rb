class AddAwardWalletOnboardingToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :aw_in_survey, :boolean, default: false, null: false, index: true

    Account.where(
      id: Person.where.not(award_wallet_email: nil).pluck(:account_id).uniq
    ).update_all(aw_in_survey: true)

    remove_column :people, :award_wallet_email, :string
  end
end
