class CardRecommendationsController < CardsController
  def update
    respond_to do |f|
      f.json do
        case params[:card][:action]
        when 'apply'
          run CardRecommendation::UpdateStatus::Applied do |result|
            render json: CardRecommendation::Representer.new(result['model']).to_json
            return
          end
          render json: { error: true, message: result['error'] }, code: 422
        else
          # we're moving away from ApplicationSurvey; I want to replace
          # everything with ops. Everything above the 'else' is the new style,
          # the code below 'else' is old stuff that should be phased out.
          begin
            survey = Card::ApplicationSurvey.new(card: load_card)
            survey.update!(update_params)
            render json: CardRecommendation::Representer.new(survey.card).to_json
          rescue Card::InvalidStatusError
            render json: {
              error: true,
              message: t("cards.invalid_status_error"),
            }, code: 422
          end
        end
      end
    end
  end

  def click
    @model = load_card

    raise 'unapplyable card' unless @model.applyable?

    # We can't know for sure here if the user has actually applied; the most we
    # can do is note that they've visited this page and (hopefully) been
    # redirected to the bank's page
    @model.update_attributes!(clicked_at: Time.zone.now)
    redirect_to @model.offer.link
  end

  def decline
    result = run(CardRecommendation::Decline)
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
