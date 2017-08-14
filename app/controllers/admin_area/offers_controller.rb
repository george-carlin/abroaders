module AdminArea
  class OffersController < AdminController
    def index
      if params[:card_product_id]
        card_product = CardProduct.find(params[:card_product_id])
        offers = card_product.offers
      else
        offers = Offer.includes(:card_product)
      end
      render cell(Offers::Cell::Index, offers, card_product: card_product)
    end

    def show
      offer = Offer.find(params[:id])
      render cell(Offers::Cell::Show, offer)
    end

    def new
      run Offers::New
      render cell(Offers::Cell::New, @model, form: @form)
    end

    def create
      run Offers::Create do
        flash[:success] = 'Offer was successfully created.'
        redirect_to admin_offer_path(@model)
        return
      end
      render cell(Offers::Cell::New, @model, form: @form)
    end

    def edit
      run Offers::Edit do
        render cell(Offers::Cell::Edit, @model, form: @form)
        return
      end
      raise 'this should never happen!'
    end

    def update
      run Offers::Update do
        flash[:success] = 'Offer was successfully updated.'
        redirect_to admin_offer_path(@model)
        return
      end
      render cell(Offers::Cell::Edit, @model, form: @form)
    end

    def kill
      run Offers::Kill
      flash[:success] = 'Killed offer'
      redirect_to request.referer
    end

    def replace
      run Offers::Replace
      flash[:success] = 'Replace offer of active recs!'
      redirect_to admin_offer_path(@model)
    end

    def unkill
      offer = Offer.find(params[:id])
      offer.update!(killed_at: nil)
      flash[:success] = 'Offer is no longer dead'
      redirect_to admin_offer_path(offer)
    end

    def verify
      run Offers::Verify
      flash[:success] = 'Verified offer'
      redirect_to request.referer
    end
  end
end
