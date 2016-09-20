class AirportsController < AuthenticatedUserController
  skip_before_action :redirect_if_onboarding_survey_incomplete!, only: [:index]

  def index
    @airports = Airport.joins(:parent).order(code: :asc)

    respond_to do |format|
      format.json do
        fresh_when last_modified: @airports.maximum(:updated_at),
                   etag: @airports.cache_key
      end
    end
  end

  def survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(account: @account)
  end

  def save_survey
    @account = current_account
    @survey = HomeAirportsSurvey.new(survey_params)

    if @survey.save
      redirect_to current_account.onboarding_survey.current_page.path
    else
      render :survey
    end
  end

  private

  def survey_params
    survey_params = params.require(:airports_survey).permit(airport_ids: [])
    survey_params.merge(account: @account).to_h
  end
end
