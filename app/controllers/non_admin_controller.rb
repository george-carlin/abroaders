# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin users.
class NonAdminController < AuthenticatedController

  before_action { redirect_to root_path if current_user.try(:admin?) }
  before_action :redirect_to_survey_if_incomplete

  protected

  def redirect_to_survey_if_incomplete
    if current_user.has_completed_user_info_survey?
      if !current_user.info.has_completed_card_survey?
        redirect_to card_survey_path unless request.path == card_survey_path
      end
    elsif controller_name != "user_infos"
      redirect_to survey_path unless request.path == survey_path
    end
  end
end
