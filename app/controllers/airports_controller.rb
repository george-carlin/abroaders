class AirportsController < AuthenticatedUserController
  skip_before_action :redirect_if_onboarding_survey_incomplete!, only: [:index]

  def index
    @airports = Airport.includes(:parent).order(code: :asc)

    respond_to do |format|
      format.json do
        fresh_when last_modified: @airports.maximum(:updated_at),
                   etag: @airports.cache_key
      end
    end
  end
end
