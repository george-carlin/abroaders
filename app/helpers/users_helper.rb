module UsersHelper

  def user_pretty_citizenship(user)
    key = user.citizenship == "neither" ? "not_citizen" : user.citizenship
    t("activerecord.attributes.user_info.citizenships.#{key}")
  end

  def user_email_with_icon(user)
    content_tag :div, class: "user-info-attr user-email" do
      fa_icon("envelope", class: "contact-info-label") + \
      raw("&nbsp") + \
      @user.email
    end
  end

end
