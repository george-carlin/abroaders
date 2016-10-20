class AirportsController < AuthenticatedUserController
  # 'index' action is required for home airports survey to load airport data
  # for the typeahead
  onboard :home_airports, with: :index

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
