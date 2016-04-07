class RenameCardsActiveToOnSurvey < ActiveRecord::Migration[5.0]
  def change
    rename_column :cards, :active, :shown_on_survey
  end
end
