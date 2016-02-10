class AddHasCompletedBalancesSurveyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :has_completed_balances_survey, :boolean,
                                                null: false, default: false
  end
end
