class CardRecommendationsController < CardsController
  def update
    survey = Card::ApplicationSurvey.new(account: load_card)
    respond_to do |f|
      f.json do
        begin
          survey.update!(update_params)
          render json: survey.account
        rescue Card::InvalidStatusError
          render json: {
            error: true,
            message: t("cards.invalid_status_error"),
          }, code: 422
        end
      end
    end
  end

  def apply
    @account = load_card

    # Make sure this is the right type of card account:
    redirect_to(cards_path) && return unless @account.applyable?

    # We can't know for sure here if the user has actually applied; the most we
    # can do is note that they've visited this page and (hopefully) been
    # redirected to the bank's page
    @account.update_attributes!(clicked_at: Time.now)
    @product = @account.product
  end

  def decline
    @account = load_card

    # Make sure this is the right type of card account:
    if @account.declinable?
      @account.update_attributes!(decline_params)
      flash[:success] = t("cards.index.declined")
    else
      flash[:info] = t("cards.index.couldnt_decline")
    end
    redirect_to cards_path
  end

  private

  def load_card
    current_account.cards.find(params[:id])
  end

  def decline_params
    params.require(:card).permit(:decline_reason).merge(declined_at: Time.now)
  end

  def update_params
    result = params.require(:card).permit(:action)
    if params[:card][:opened_at]
      result[:opened_at] = Date.strptime(params[:card][:opened_at], "%m/%d/%Y")
    end
    result
  end
end
