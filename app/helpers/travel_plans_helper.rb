module TravelPlansHelper

  def link_to_skip_survey
    link_to(
        "I don't want to add a travel plan right now",
        skip_survey_travel_plans_path,
        method: :patch,
    )
  end
end