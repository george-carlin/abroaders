class AddHasCompletedBalancesSurveyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :user_infos, :has_completed_balances_survey, :boolean,
                                                null: false, default: false
  end
end
