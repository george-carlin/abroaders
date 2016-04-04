module AdminArea
  class CardsController < AdminController

    # GET /admin/cards
    def index
      @cards = Card.order(:identifier)
    end

    # GET /admin/cards/1
    def show
      @card = get_card
    end

    # GET /admin/cards/new
    def new
      @card = Card.new
    end

    # GET /admin/cards/1/edit
    # Unimplemented
    # def edit
    #   @card = get_card
    # end

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

    # PATCH/PUT /admin/cards/1
    # Unimplemented
    # def update
    #   @card = get_card
    #   if @card.update(card_params)
    #       redirect_to @card, notice: 'Card was successfully updated.'
    #   else
    #     render :edit
    #   end
    # end

    # DELETE /admin/cards/1
    # def destroy
    #   @card = get_card
    #   @card.destroy
    #   redirect_to cards_url, notice: 'Card was successfully destroyed.'
    # end

    def active
      @card = get_card
      @card.toggle!(:active)
      respond_to do |f|
        f.js
      end
    end


    private

    def get_card
      Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(
        :identifier, :name, :network, :bp, :type, :annual_fee
      )
    end

  end
end
