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
      offer = Offer.find(params[:id])
      render cell(Offers::Cell::Show, offer)
    end

    def new
      run Offers::Operation::New
      render cell(Offers::Cell::New, @model, form: @form)
    end

    def edit
      run Offers::Operation::Edit do
        render cell(Offers::Cell::Edit, @model, form: @form)
        return
      end
      raise 'this should never happen!'
    end

    def create
      run Offers::Operation::Create do
        flash[:success] = 'Offer was successfully created.'
        redirect_to admin_offer_path(@model)
        return
      end
      render cell(Offers::Cell::New, @model, form: @form)
    end

    def update
      run Offers::Operation::Update do
        flash[:success] = 'Offer was successfully updated.'
        redirect_to admin_offer_path(@model)
        return
      end
      render cell(Offers::Cell::Edit, @model, form: @form)
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

    private

    def load_product
      CardProduct.find(params[:card_product_id])
    end
  end
end
