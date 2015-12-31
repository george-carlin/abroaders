module Admin
  class CardsController < ApplicationController

    # GET /admin_panel/cards
    def index
      @cards = Card.all
    end

    # GET /admin_panel/cards/1
    def show
      @card = get_card
    end

    # # GET /admin_panel/cards/new
    # def new
    #   @card = Card.new
    # end

    # # GET /admin_panel/cards/1/edit
    # def edit
    #   @card = get_card
    # end

    # # POST /admin_panel/cards
    # def create
    #   @card = Card.new(card_params)

    #   if @card.save
    #     redirect_to @card, notice: 'Card was successfully created.'
    #   else
    #     render :new
    #   end
    # end

    # # PATCH/PUT /admin_panel/cards/1
    # def update
    #   @card = get_card
    #   if @card.update(card_params)
    #       redirect_to @card, notice: 'Card was successfully updated.'
    #   else
    #     render :edit
    #   end
    # end

    # # DELETE /admin_panel/cards/1
    # def destroy
    #   @card = get_card
    #   @card.destroy
    #   redirect_to cards_url, notice: 'Card was successfully destroyed.'
    # end

    private

    def get_card
      Card.find(params[:id])
    end

    # # Never trust parameters from the scary internet, only allow the white list through.
    # def card_params
    #   params[:card]
    # end
  end
end
