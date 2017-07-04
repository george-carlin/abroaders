module AdminArea
  class CardProductsController < AdminController
    before_action :check_currencies!, if: "Rails.env.development?"

    # GET /admin/cards
    def index
      @products = CardProduct.all.includes(:offers, :currency).sort_by(&:bank_id)
    end

    # GET /admin/cards/1
    def show
      @product = CardProduct.includes(:currency).find(params[:id])
    end

    # GET /admin/cards/new
    def new
      render cell(CardProducts::Cell::New, CardProduct.new)
    end

    # POST /admin/cards
    def create
      product = CardProduct.new(card_product_params)

      if product.valid?
        file = params[:card_product].delete(:image)

        CardProduct::ProcessImage.(product, file).save!
        flash[:success] = 'Card product was successfully created.'
        redirect_to admin_card_product_path(product)
      else
        render cell(CardProducts::Cell::New, product)
      end
    end

    # GET /admin/cards/1/edit
    def edit
      product = CardProduct.find(params[:id])
      render cell(CardProducts::Cell::Edit, product)
    end

    # PATCH/PUT /admin/cards/1
    def update
      product = CardProduct.find(params[:id])
      if product.update(card_product_params)
        redirect_to admin_card_product_path(product), notice: 'Card product was successfully updated.'
      else
        render cell(CardProducts::Cell::Edit, product)
      end
    end

    def images
      @products = CardProduct.all
    end

    private

    def card_product_params
      params.require(:card_product).permit(
        :name, :network, :personal, :type, :annual_fee, :bank_id, :currency_id,
        :shown_on_survey,
      )
    end

    def check_currencies!
      raise "no Currencies in the database" unless Currency.any?
    end
  end
end
