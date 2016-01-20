# Superclass for all controllers whose actions are intended to be used by
# 'normal', non-admin users.
class NormalUserController < AuthenticatedController

  before_action :redirect_to_onboarding_survey_if_incomplete

  protected

  def redirect_to_onboarding_survey_if_incomplete
    return true # FIXME
    if !current_user.info.try(:persisted?) && controller_name != "user_infos"
      redirect_to new_info_path and return
    end
  end
end
