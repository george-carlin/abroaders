# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin users.
class NonAdminController < AuthenticatedController

  before_action { redirect_to root_path if current_user.try(:admin?) }
  before_action :redirect_to_survey_if_incomplete

  protected

  def redirect_to_survey_if_incomplete
    if !current_user.info.try(:persisted?) && controller_name != "user_infos"
      redirect_to survey_path and return
    end
  end
end
