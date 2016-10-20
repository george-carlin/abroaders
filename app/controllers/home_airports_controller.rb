class HomeAirportsController < AuthenticatedUserController
  onboard :home_airports, with: [:survey, :save_survey]

  def survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(account: @account)
  end

  def save_survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(survey_params)

    if @survey.save
      redirect_to onboarding_survey_path
    else
      render :survey
    end
  end

  private

  def survey_params
    survey_params = params.require(:home_airports_survey).permit(airport_ids: [])
    survey_params.merge(account: @account)
  end
end
