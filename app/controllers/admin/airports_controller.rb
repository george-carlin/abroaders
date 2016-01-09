module Admin
  class AirportsController < AdminController

    def index
      @airports = Airport.order("iata_code ASC")
    end

  end
end
