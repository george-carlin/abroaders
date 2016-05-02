module AdminArea
  class OffersController < AdminController
    def index
      @offers = Offer.includes(:card)
    end

    def show
      @offer = get_offer
    end

    def new
      @offer = Offer.new
    end

    def edit
      @offer = get_offer
    end

    def create
      @offer = Offer.new(offer_params)

      if @offer.save
        flash[:success] = "Offer was successfully created."
        redirect_to admin_offer_path(@offer)
      else
        render :new
      end
    end

    def update
      @offer = get_offer
      if @offer.update_attributes(offer_params)
        flash[:success] = "Offer was successfully updated."
        redirect_to admin_offer_path(@offer)
      else
        render :edit
      end
    end

    private

    def get_offer
      Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(
        :card_id, :condition, :points_awarded, :spend, :cost, :days, :live,
        :link, :notes,
      )
    end
  end
end
