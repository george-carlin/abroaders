module CardsSurveyHelper
  def options_for_cards_survey_month_select(without_wrapping: false)
    options = Date::MONTHNAMES.compact.map.with_index { |m, i| [m.first(3), i + 1] }
    if without_wrapping
      options
    else
      options_for_select(
        options,
      )
    end
  end

  def options_for_cards_survey_year_select(without_wrapping: false)
    options = (Date.today.year - 15)..Date.today.year
    if without_wrapping
      options
    else
      options_for_select options, Date.today.year
    end
  end
end
