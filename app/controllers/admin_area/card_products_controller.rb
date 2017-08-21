module AdminArea
  class CardProductsController < AdminController
    before_action :check_currencies!, if: "Rails.env.development?"

    # GET /admin/cards
    def index
      products = CardProduct.all.includes(:offers, :currency).sort_by(&:bank_id)
      render cell(CardProducts::Cell::Index, products)
    end

    # GET /admin/cards/1
    def show
      product = CardProduct.includes(:currency).find(params[:id])
      render cell(CardProducts::Cell::Show, product)
    end

    # GET /admin/cards/new
    def new
      run CardProducts::New
      render cell(CardProducts::Cell::New, @model, form: @form)
    end

    # POST /admin/cards
    def create
      run CardProducts::Create do
        flash[:success] = 'Card product was successfully created.'
        redirect_to admin_card_product_path(@model)
        return
      end
      render cell(CardProducts::Cell::New, @model, form: @form)
    end

    # GET /admin/cards/1/edit
    def edit
      run CardProducts::Edit
      render cell(CardProducts::Cell::Edit, @model, form: @form)
    end

    # PATCH/PUT /admin/cards/1
    def update
      run CardProducts::Update do
        flash[:success] = 'Card product was successfully updated.'
        redirect_to admin_card_product_path(@model)
        return
      end
      render cell(CardProducts::Cell::Edit, @model, form: @form)
    end

    def images
      render cell(CardProducts::Cell::Images, CardProduct.all)
    end

    private

    def check_currencies!
      raise "no Currencies in the database" unless Currency.any?
    end
  end
end
