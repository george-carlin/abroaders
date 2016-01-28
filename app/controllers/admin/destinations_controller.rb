module Admin
  class DestinationsController < AdminController

    def index
      @type = "destination"
      @destinations = Destination.includes(:parent).all
    end

    Destination::TYPES.each do |type|
      define_method type do
        @type = type
        @destinations = Destination.includes(:parent).send(type)
        render :index
      end
    end

  end
end
