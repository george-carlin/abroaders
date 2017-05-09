class AddPhoneNumberToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :phone_number, :string
    add_column :accounts, :phone_number_normalized, :string
    add_index :accounts, :phone_number_normalized
  end
end
