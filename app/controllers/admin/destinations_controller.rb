module Admin
  class DestinationsController < AdminController

    def index
      @type = "destination"
      @destinations = load_destinations.all
    end

    Destination::TYPES.each do |type|
      define_method type do
        @type = type
        @destinations = load_destinations.send(type)
        render :index
      end
    end

    private

    def load_destinations
      Destination.includes(:parent).order("name ASC").paginate(
        page: params[:page], per_page: 50
      )
    end

  end
end
