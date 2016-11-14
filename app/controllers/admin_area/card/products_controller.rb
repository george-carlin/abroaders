module AdminArea
  module Card
    class ProductsController < AdminController
      before_action :check_currencies!, if: "Rails.env.development?"

      # GET /admin/cards
      def index
        @products = ::Card::Product.all.includes(:offers, :currency, :bank).sort_by(&:identifier)
      end

      # GET /admin/cards/1
      def show
        @product = load_card_product
      end

      # GET /admin/cards/new
      def new
        @product = ::Card::Product.new
      end

      # POST /admin/cards
      def create
        @product = ::Card::Product.new(card_product_params)

        if @product.save
          flash[:success] = 'Card product was successfully created.'
          redirect_to admin_card_product_path(@product)
        else
          render :new
        end
      end

      # GET /admin/cards/1/edit
      def edit
        @product = load_card_product
      end

      # PATCH/PUT /admin/cards/1
      def update
        @product = load_card_product
        if @product.update(card_product_params)
          redirect_to admin_card_product_path(@product), notice: 'Card product was successfully updated.'
        else
          render :edit
        end
      end

      def images
        @products = ::Card::Product.all
      end

      private

      def load_card_product
        ::Card::Product.find(params[:id])
      end

      def card_product_params
        params.require(:card_product).permit(
          :code, :name, :network, :bp, :type, :annual_fee, :bank_id, :currency_id,
          :shown_on_survey, :image,
        )
      end

      def check_currencies!
        raise "no Currencies in the database" unless Currency.any?
      end
    end
  end
end
