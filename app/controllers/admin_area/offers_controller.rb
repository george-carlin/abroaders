module AdminArea
  class OffersController < AdminController
    def index
      if params[:card_product_id]
        @product = CardProduct.find(params[:card_product_id])
        @offers  = @product.offers
      else
        @offers = Offer.includes(product: :bank)
      end
    end

    def show
      if params[:card_product_id]
        product = CardProduct.find(params[:card_product_id])
        offer   = product.offers.find(params[:id])
        render cell(Offers::Cell::Show, offer)
      else
        offer = Offer.includes(:product).find(params[:id])
        redirect_to admin_card_product_offer_path(offer.product, offer)
      end
    end

    def new
      run Offers::Operation::New
    end

    def edit
      run Offers::Operation::Edit do
        return
      end
      redirect_to edit_admin_card_product_offer_path(@model.product, @model)
    end

    def create
      run Offers::Operation::Create do
        flash[:success] = 'Offer was successfully created.'
        redirect_to admin_offer_path(@model)
        return
      end
      render :new
    end

    def update
      run Offers::Operation::Update do
        flash[:success] = 'Offer was successfully updated.'
        redirect_to admin_offer_path(@model)
        return
      end
      render :edit
    end

    def kill
      run Offers::Operation::Kill
      respond_to { |f| f.js }
    end

    def review
      @offers = Offer.includes(product: :bank).live.order('last_reviewed_at ASC NULLS FIRST')
    end

    def verify
      run Offers::Operation::Verify
      respond_to { |f| f.js }
    end
  end
end
