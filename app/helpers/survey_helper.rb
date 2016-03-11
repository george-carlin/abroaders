module SurveyHelper

  # Wrapper method so we can get all three form helpers without having
  # to indent the ERB file three times:
  def passenger_survey_form(survey)
    raise unless survey.is_a?(PassengerSurvey) # sanity check
    form_for survey, url: survey_passengers_path, method: :post do |fields|
      fields_for(
        "passenger_survey[main_passenger_attributes]",
        survey.main_passenger
      ) do |mp_fields|
        fields_for(
          "passenger_survey[companion_attributes]",
          survey.companion
        ) do |co_fields|
          yield fields, mp_fields, co_fields
        end
      end
    end
  end

end
