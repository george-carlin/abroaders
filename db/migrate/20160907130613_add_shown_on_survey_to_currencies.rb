class AddShownOnSurveyToCurrencies < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :shown_on_survey, :boolean, null: false, default: true
  end
end
