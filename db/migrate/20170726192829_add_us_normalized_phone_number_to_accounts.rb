class AddUsNormalizedPhoneNumberToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :phone_number_us_normalized, :string, index: true
  end
end
