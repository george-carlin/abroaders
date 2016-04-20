module CardsSurveyHelper

  def options_for_cards_survey_month_select
    options_for_select(
      Date::MONTHNAMES.compact.map.with_index { |m, i| [m.first(3), i+1] },
    )
  end

  def options_for_cards_survey_year_select
    options_for_select (Date.today.year - 15)..Date.today.year, Date.today.year
  end

end
