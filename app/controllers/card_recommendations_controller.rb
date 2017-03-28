class CardRecommendationsController < CardsController
  def update
    survey = Card::ApplicationSurvey.new(card: load_card)
    respond_to do |f|
      f.json do
        begin
          survey.update!(update_params)
          render json: survey.card
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
    @model = load_card

    raise 'unapplyable card' unless @model.applyable?

    # We can't know for sure here if the user has actually applied; the most we
    # can do is note that they've visited this page and (hopefully) been
    # redirected to the bank's page
    @model.update_attributes!(clicked_at: Time.zone.now)
  end

  def decline
    result = run CardRecommendation::Operation::Decline
    if result.success?
      flash[:success] = t("cards.index.declined")
    else
      flash[:info] = result['error']
    end
    redirect_to cards_path
  end

  private

  def load_card
    current_account.cards.find(params[:id])
  end

  def update_params
    result = params.require(:card).permit(:action)
    if params[:card][:opened_on]
      result[:opened_on] = Date.strptime(params[:card][:opened_on], "%m/%d/%Y")
    end
    result
  end
end
