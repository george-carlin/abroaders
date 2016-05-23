class CardRecommendationsController < CardAccountsController

  def apply
    @recommendation = load_card_account

    # Make sure this is the right type of card account:
    redirect_to card_accounts_path and return unless @recommendation.recommendation?

    # We can't know for sure if the user has actually applied; the most
    # we can do is note that they've visited this page and (hopefully)
    # been redirected to the bank's page
    @recommendation.update_attributes!(clicked_at: Time.now)
    @card = @recommendation.card
  end

  def decline
    raise "decline message must be present" unless decline_reason.present?
    @recommendation = load_card_account

    # TODO replace with a policy object and 'applyable?'
    if @recommendation.recommendation?
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

end
