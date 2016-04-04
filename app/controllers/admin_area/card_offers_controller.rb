module AdminArea
  class CardOffersController < AdminController
    def index
      @card_offers = CardOffer.includes(:card)
    end

    def show
      @card_offer = get_card_offer
    end

    def new
      @card_offer = CardOffer.new
    end

    def edit
      @card_offer = get_card_offer
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

    def update
      @card_offer = get_card_offer
      if @card_offer.update_attributes(card_offer_params)
        flash[:success] = "Card offer was successfully updated."
        redirect_to admin_card_offer_path(@card_offer)
      else
        render :edit
      end
    end

    def destroy
      @card_offer = get_card_offer
      @card_offer.destroy
      flash[:success] = "Card offer was successfully destroyed."
      redirect_to admin_card_offers_path
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
