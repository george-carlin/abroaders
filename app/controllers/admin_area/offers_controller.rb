module AdminArea
  class OffersController < AdminController
    def index
      if params[:card_id]
        @card   = load_card
        @offers = @card.offers
      else
        @offers = Offer.includes(:card)
      end
    end

    def show
      if params[:card_id]
        @card  = load_card
        @offer = @card.offers.find(params[:id])
      else
        @offer = Offer.find(params[:id])
        redirect_to admin_card_offer_path(@offer.card, @offer)
      end
    end

    def new
      @card  = load_card
      @offer = @card.offers.build
    end

    def edit
      if params[:card_id]
        @card  = load_card
        @offer = @card.offers.find(params[:id])
      else
        @offer = Offer.find(params[:id])
        redirect_to edit_admin_card_offer_path(@offer.card, @offer)
      end
    end

    def create
      @card  = load_card
      @offer = @card.offers.build(offer_params)

      if @offer.save
        flash[:success] = "Offer was successfully created."
        redirect_to admin_offer_path(@offer)
      else
        render :new
      end
    end

    def update
      @offer = load_offer
      if @offer.update_attributes(offer_params)
        flash[:success] = "Offer was successfully updated."
        redirect_to admin_offer_path(@offer)
      else
        render :edit
      end
    end

    def kill
      @offer = Offer.live.find(params[:id])
      @offer.killed_at = DateTime.now
      @offer.save!
      respond_to do |format|
        format.js
      end
    end

    def review
      @offers = Offer.includes(:card).live.order('last_reviewed_at ASC NULLS FIRST')
    end

    def verify
      @offer = Offer.live.find(params[:id])
      @offer.last_reviewed_at = DateTime.now
      @offer.save!
      respond_to do |format|
        format.js
      end
    end

    private

    def load_card
      Card.find(params[:card_id])
    end

    def load_offer
      Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(
        :condition, :points_awarded, :spend, :cost, :days,
        :link, :partner, :notes,
      )
    end
  end
end
