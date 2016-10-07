module TravelPlansHelper

  def link_to_skip_survey
    link_to(
        "I don't have specific plans",
        skip_survey_travel_plans_path,
        method: :patch,
        class: "btn btn-block skip-survey-btn form-control"
    )
  end

  def options_for_travel_plan_country_select(countries)
    countries.map { |c| [c.name, c.id, { 'data-code' => c.code }] }
  end
end
