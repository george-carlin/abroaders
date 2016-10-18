module TravelPlansHelper
  def link_to_skip_survey
    link_to(
        "I don't have specific plans",
        skip_survey_travel_plans_path,
        method: :patch,
        class: "btn btn-block skip-survey-btn form-control"
    )
  end
end
