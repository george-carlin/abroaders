module AdminArea
  class CardsController < AdminController
    before_action :check_currencies!, if: "Rails.env.development?"

    # GET /admin/cards
    def index
      @cards = Card.all.includes(:offers, :currency).sort_by(&:identifier)
    end

    # GET /admin/cards/1
    def show
      @card = load_card
    end

    # GET /admin/cards/new
    def new
      @card = Card.new
    end

    # POST /admin/cards
    def create
      @card = Card.new(card_params)

      if @card.save
        flash[:success] = "Card was successfully created."
        redirect_to admin_card_path(@card)
      else
        render :new
      end
    end

    # GET /admin/cards/1/edit
    def edit
      @card = load_card
    end

    # PATCH/PUT /admin/cards/1
    def update
      @card = load_card
      if @card.update(card_params)
        # TODO redirect to @card once that page is ready
        redirect_to admin_card_path(@card), notice: 'Card was successfully updated.'
      else
        render :edit
      end
    end

    def images
      @cards = Card.all
    end

    private

    def load_card
      Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(
        :code, :name, :network, :bp, :type, :annual_fee, :bank_id, :currency_id,
        :shown_on_survey, :image,
      )
    end

    def check_currencies!
      raise "no Currencies in the database" unless Currency.any?
    end
  end
end
