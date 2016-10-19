module SurveyHelper
  def has_business_label_text(value)
    case value
    when "with_ein"
      "Yes, and I have an EIN (Employer ID Number)"
    when "without_ein"
      "Yes, but I do not have an EIN - I am a freelancer or sole proprietor"
    when "no_business"
      "I do not own a business"
    end
  end

  def progress_info_class(state, left_edge, right_edge)
    if state < left_edge
      "on-hold"
    elsif state > right_edge
      "completed"
    else
      "in-progress"
    end
  end
end
