module AdminArea
  class OffersController < AdminController
    def index
      if params[:card_product_id]
        @product = CardProduct.find(params[:card_product_id])
        @offers  = @product.offers
      else
        @offers = Offer.includes(:card_product)
      end
    end

    def show
      if params[:card_product_id]
        card_product = CardProduct.find(params[:card_product_id])
        offer = card_product.offers.find(params[:id])
        render cell(Offers::Cell::Show, offer)
      else
        offer = Offer.includes(:card_product).find(params[:id])
        redirect_to admin_card_product_offer_path(offer.card_product, offer)
      end
    end

    def new
      run Offers::New
    end

    def edit
      run Offers::Edit do
        return
      end
      redirect_to edit_admin_card_product_offer_path(@model.card_product, @model)
    end

    def create
      run Offers::Create do
        flash[:success] = 'Offer was successfully created.'
        redirect_to admin_offer_path(@model)
        return
      end
      render :new
    end

    def update
      run Offers::Update do
        flash[:success] = 'Offer was successfully updated.'
        redirect_to admin_offer_path(@model)
        return
      end
      render :edit
    end

    def kill
      run Offers::Kill
      respond_to { |f| f.js }
    end

    def review
      @offers = Offer.includes(:card_product).live.order('last_reviewed_at ASC NULLS FIRST')
    end

    def verify
      run Offers::Verify
      respond_to { |f| f.js }
    end
  end
end
