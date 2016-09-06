module SurveyHelper

  def has_business_label_text(value, name)
    case value
    when "with_ein"
      "Yes, and #{name.i} #{name.has} an EIN (Employer ID Number)"
    when "without_ein"
      "Yes, but #{name.i} #{name.doesnt_have} an EIN - #{name.i_am} a freelancer or sole proprietor"
    when "no_business"
      "#{name.i.capitalize} #{name.doesnt} own a business"
    end
  end

end


