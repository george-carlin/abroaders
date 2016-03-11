class AddFieldsForCompanionSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :passengers, :willing_to_apply, :boolean, default: true, null: false
    remove_column :passengers, :time_zone, :string, null: false
    add_column :accounts, :time_zone, :string
    add_column :accounts, :shares_expenses, :boolean, default: false, null: false

    remove_column :passengers, :credit_score,                        null: false
    remove_column :passengers, :will_apply_for_loan, default: false, null: false
    remove_column :passengers, :personal_spending,   default: 0,     null: false
    remove_column :passengers, :business_spending,   default: 0
    remove_column :passengers, :has_business,        default: 0,     null: false
  end
end
