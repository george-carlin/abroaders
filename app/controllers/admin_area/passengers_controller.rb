module AdminArea
  class PassengersController < AdminController

    # GET /admin/passengers/1
    def show
      @passenger           = get_passenger
      @card_accounts       = @passenger.card_accounts.select(&:persisted?)
      @card_recommendation = @passenger.card_accounts.new
      # Use @passenger.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @cards = Card.where.not(id: @passenger.card_accounts.select(:card_id))
    end

    private

    def get_passenger
      Passenger.find(params[:id])
    end

  end
end
