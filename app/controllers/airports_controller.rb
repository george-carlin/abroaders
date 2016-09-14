class AirportsController < AuthenticatedUserController
  skip_before_action :redirect_if_onboarding_survey_incomplete!, only: [:index]

  def index
    @airports = Airport.joins(:parent)

    respond_to do |format|
      format.json do
        fresh_when last_modified: @airports.maximum(:updated_at),
                   etag: @airports.cache_key
      end
    end
  end

  def survey
    @account = current_account
    @survey = AirportsSurvey.new(account: @account)
  end

  def save_survey
    @account = current_account
    @survey = AirportsSurvey.new(survey_params.merge(account: @account))
    if @survey.save
      redirect_to current_account.onboarding_survey.current_page.path
    else
      render :survey
    end
  end

  private

  def survey_params
    params.require(:airports_survey).permit(home_airports_ids: []).to_h
  end
end
