module AdminArea
  class OffersController < AdminController
    def index
      if params[:card_product_id]
        @product = load_product
        @offers  = @product.offers
      else
        @offers = Offer.includes(product: :bank)
      end
    end

    def show
      if params[:card_product_id]
        product = load_product
        offer   = product.offers.find(params[:id])
        render cell(Offers::Cell::Show, offer)
      else
        offer = Offer.find(params[:id])
        redirect_to admin_card_product_offer_path(offer.product, offer)
      end
    end

    def new
      @product = load_product
      @offer   = Offers::Form.new(@product.offers.build)
    end

    def edit
      if params[:card_product_id]
        @product = load_product
        @offer   = Offers::Form.new(@product.offers.find(params[:id]))
      else
        @offer = Offer.find(params[:id])
        redirect_to edit_admin_card_product_offer_path(@offer.product, @offer)
      end
    end

    def create
      @product = load_product
      @offer   = Offers::Form.new(@product.offers.build)

      if @offer.validate(params[:offer])
        @offer.save
        flash[:success] = 'Offer was successfully created.'
        redirect_to admin_offer_path(@offer)
      else
        render :new
      end
    end

    def update
      @offer = Offers::Form.new(Offer.find(params[:id]))
      if @offer.validate(params[:offer])
        @offer.save
        flash[:success] = 'Offer was successfully updated.'
        redirect_to admin_offer_path(@offer)
      else
        render :edit
      end
    end

    def kill
      run Offers::Operation::Kill
      respond_to { |f| f.js }
    end

    def review
      @offers = Offer.includes(product: :bank).live.order('last_reviewed_at ASC NULLS FIRST')
    end

    def verify
      @offer = Offer.live.find(params[:id])
      @offer.last_reviewed_at = Time.zone.now
      @offer.save!
      respond_to do |format|
        format.js
      end
    end

    private

    def load_product
      CardProduct.find(params[:card_product_id])
    end
  end
end
