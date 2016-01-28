module Admin
  class DestinationsController < AdminController

    def index
      @type = "destination"
      @destinations = Destination.all
    end

    Destination.types.keys.each do |type|
      define_method type do
        @type = type
        @destinations = Destination.send(type)
        render :index
      end
    end

  end
end
