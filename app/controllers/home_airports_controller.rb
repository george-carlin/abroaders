class HomeAirportsController < AuthenticatedUserController
  before_action :redirect_if_survey_already_completed!, only: [:survey, :save_survey]

  def survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(account: @account)
  end

  def save_survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(survey_params)

    if @survey.save
      redirect_to onboarding_survey.current_path
    else
      render :survey
    end
  end

  private

  def redirect_if_survey_already_completed!
    survey = current_account.onboarding_survey
    return if survey.home_airports?
    if survey.complete?
      redirect_to root_path
    else
      redirect_to account_onboarding_survey_path(current_account)
    end
  end

  def survey_params
    survey_params = params.require(:home_airports_survey).permit(airport_ids: [])
    survey_params.merge(account: @account).to_h
  end
end
