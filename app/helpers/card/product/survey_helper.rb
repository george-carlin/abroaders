module Card::Product::SurveyHelper
  # TODO couldn't this be replaced with Rails's 'date_select'?
  def options_for_cards_survey_month_select
    options = Date::MONTHNAMES.compact.map.with_index { |m, i| [m.first(3), i + 1] }
    options_for_select options
  end

  def options_for_cards_survey_year_select
    options = (Date.today.year - 15)..Date.today.year
    options_for_select options, Date.today.year
  end
end
