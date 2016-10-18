class AirportsController < AuthenticatedUserController
  # 'index' action is required for home airports survey and travel plan
  # to load airport data for the typeahead
  onboard :home_airports, :travel_plan, :complete, with: :index

  def index
    @airports = Airport.joins(:parent).order(code: :asc)

    respond_to do |format|
      format.json do
        fresh_when last_modified: @airports.maximum(:updated_at),
                   etag: @airports.cache_key
      end
    end
  end
end
