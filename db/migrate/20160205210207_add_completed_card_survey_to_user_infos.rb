class AddCompletedCardSurveyToUserInfos < ActiveRecord::Migration[5.0]
  def change
    add_column :user_infos, :has_completed_card_survey, :boolean,
                                        default: false, null: false
  end
end
