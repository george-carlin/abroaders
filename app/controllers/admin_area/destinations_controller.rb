module AdminArea
  class DestinationsController < AdminController
    def index
      destinations = load_destinations.all
      render cell(Destinations::Cell::Index, destinations, page: params[:page], page_type: 'destination')
    end

    Destination::TYPES.each do |type|
      define_method type do
        destinations = load_destinations.send(type)
        render cell(Destinations::Cell::Index, destinations, page_type: type)
      end
    end

    private

    def load_destinations
      Destination.includes(:parent).order('name ASC')
    end
  end
end
