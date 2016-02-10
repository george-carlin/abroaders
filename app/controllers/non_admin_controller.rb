# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin users.
class NonAdminController < AuthenticatedController

  before_action { redirect_to root_path if current_user.try(:admin?) }
  before_action :redirect_to_survey_if_incomplete

  protected

  def redirect_to_survey_if_incomplete
    # The path to the current stage of the survey that the user needs to
    # complete. nil if the user has completed all survey stages:
    current_survey_path = nil

    {
      # method to test if stage is complete =>
      #             path to redirect to if stage is not complete
      :has_completed_user_info_survey? => survey_user_info_path,
      :has_completed_cards_survey?     => survey_card_accounts_path,
      :has_completed_balances_survey?  => survey_balances_path,
    }.each do |method, path|
      if !current_user.send(method)
        current_survey_path = path
        break
      end
    end

    if current_survey_path && current_survey_path != request.path
      redirect_to current_survey_path
    end
  end
end
