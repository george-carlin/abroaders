module SurveyHelper

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


