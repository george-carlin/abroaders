class RemoveConfirmableFromAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :confirmation_token, :string
    remove_column :accounts, :confirmed_at, :datetime
    remove_column :accounts, :confirmation_sent_at, :datetime
    remove_column :accounts, :unconfirmed_email, :string
  end
end
