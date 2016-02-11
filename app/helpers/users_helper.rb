module UsersHelper

  def user_pretty_citizenship(user)
    key = user.citizenship == "neither" ? "not_citizen" : user.citizenship
    t("activerecord.attributes.survey.citizenships.#{key}")
  end

  def user_email_with_icon(user)
    content_tag :div, class: "survey-attr user-email" do
      fa_icon("envelope", class: "contact-info-label") + \
      raw("&nbsp") + \
      @user.email
    end
  end

end
