module AdminArea
  class CardsController < AdminController
    before_action :check_currencies!, if: "Rails.env.development?"

    # GET /admin/cards
    def index
      @cards = Card.all.includes(:offers, :currency).sort_by(&:identifier)
    end

    # GET /admin/cards/1
    def show
      @card = get_card
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
        redirect_to admin_cards_path
      else
        render :new
      end
    end

    # GET /admin/cards/1/edit
    def edit
      @card = get_card
    end

    # PATCH/PUT /admin/cards/1
    def update
      @card = get_card
      if @card.update(card_params)
        # TODO redirect to @card once that page is ready
        redirect_to admin_cards_path, notice: 'Card was successfully updated.'
      else
        render :edit
      end
    end

    private

    def get_card
      Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(
        :code, :name, :network, :bp, :type, :annual_fee, :bank_id, :currency_id,
        :shown_on_survey
      )
    end

    def check_currencies!
      raise "no Currencies in the database" unless Currency.any?
    end

  end
end
