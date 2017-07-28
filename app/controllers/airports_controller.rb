class AirportsController < ApplicationController
  # 'typeahead' action is required for home airports survey and travel plan
  # to load airport data for the typeahead

  def typeahead
    @airports = Airport.includes(:parent).order(code: :asc)

    respond_to do |format|
      format.json do
        fresh_when last_modified: @airports.maximum(:updated_at),
                   etag: @airports.cache_key
      end
    end
  end
end
