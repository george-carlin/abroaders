class CardRecommendationsController < NonAdminController

  def apply
    @recommendation = current_account.card_accounts.find(params[:id])

    # Make sure this is the right type of card account:
    # TODO perform a similar check for 'decline'
    redirect_to card_accounts_path and return unless @recommendation.recommendation?

    # We can't know for sure if the user has actually applied; the most
    # we can do is note that they've visited this page and (hopefully)
    # been redirected to the bank's page
    @recommendation.clicked!
    @card = @recommendation.card
  end

  def decline
    raise "decline message must be present" unless decline_reason.present?

    if @recommendation = load_card_recommendation
      @recommendation.decline_with_reason!(decline_reason)
      flash[:success] = t("admin.people.card_accounts.you_have_declined")
      redirect_to card_accounts_path
    else
      flash[:info] = t("card_accounts.index.couldnt_decline")
      redirect_to card_accounts_path
    end
  end

  private

  def decline_reason
    params[:card_account][:decline_reason]
  end

  def load_card_recommendation
    current_main_passenger.card_recommendations.find_by(id: params[:id])
  end

end
