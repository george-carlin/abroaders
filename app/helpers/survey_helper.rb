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

  def has_business_label_text(value, user_name)
    case value
    when "with_ein"
      if user_name == "you"
        "I have a business EIN (Employer ID Number)"
      else
        "#{user_name} has a business EIN (Employer ID Number)"
      end
    when "without_ein"
      if user_name == "you"
        "I do not have an EIN - I am a freelancer or sole proprietor"
      else
        "#{user_name} does not have an EIN - he/she is a freelancer or "\
        "sole proprietor"
      end
    when "no_business"
      if user_name == "you"
        "I do not have a business"
      else
        "#{user_name} does not have a business"
      end
    end
  end

end


