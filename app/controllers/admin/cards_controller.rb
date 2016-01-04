module Admin
  class CardsController < AdminController
    # GET /admin_panel/cards
    def index
      @cards = Card.all
    end

    # GET /admin_panel/cards/1
    def show
      @card = get_card
    end

    # GET /admin_panel/cards/new
    def new
      @card = Card.new
    end

    # GET /admin_panel/cards/1/edit
    def edit
      @card = get_card
    end

    # POST /admin_panel/cards
    def create
      @card = Card.new(card_params)

      if @card.save
        flash[:success] = "Card was successfully created."
        redirect_to admin_cards_path
      else
        render :new
      end
    end

    # PATCH/PUT /admin_panel/cards/1
    def update
      @card = get_card
      if @card.update(card_params)
          redirect_to @card, notice: 'Card was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin_panel/cards/1
    # def destroy
    #   @card = get_card
    #   @card.destroy
    #   redirect_to cards_url, notice: 'Card was successfully destroyed.'
    # end

    private

    def get_card
      Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(
        :identifier, :name, :brand, :bp, :type, :annual_fee
      )
    end

  end
end
