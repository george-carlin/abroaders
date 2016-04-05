module AdminArea
  class CardOffersController < AdminController
    def index
      @card_offers = CardOffer.includes(:card)
    end

    def new
      @card_offer = CardOffer.new
    end

    def create
      @card_offer = CardOffer.new(card_offer_params)

      if @card_offer.save
        flash[:success] = "Card offer was successfully created."
        redirect_to admin_card_offer_path(@card_offer)
      else
        render :new
      end
    end

    private

    def get_card_offer
      CardOffer.find(params[:id])
    end

    def card_offer_params
      params.require(:card_offer).permit(:card_id, :points_awarded, :spend,
                                         :cost, :days, :status)
    end
  end
end
