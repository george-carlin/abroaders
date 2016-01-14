# Superclass for all controllers whose actions are intended to be used by
# 'normal', non-admin users.
class NormalUserController < AuthenticatedController

  before_action :redirect_to_onboarding_survey_if_incomplete

  protected

  def redirect_to_onboarding_survey_if_incomplete
    if !current_user.contact_info.try(:persisted?) &&
          controller_name != "contact_infos"
      redirect_to new_contact_info_path and return
    end
    if current_user.contact_info.try(:persisted?) &&
        !current_user.spending_info.try(:persisted?) &&
          controller_name != "spending_infos"
      redirect_to new_spending_info_path and return
    end
  end
end
