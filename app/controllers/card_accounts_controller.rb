class CardAccountsController < NonAdminController
  helper CardAccountButtons

  def index
    # Just show main passenger recommendations for now:
    @new_recommendations = current_main_passenger\
                    .card_recommendations.includes(:card).order(:created_at)
    @other_accounts = current_main_passenger\
                    .card_accounts.where.not(id: @new_recommendations)\
                    .includes(:card).order(:created_at)
  end

  def apply
    # They should still be able to access this page if the card is 'applied',
    # in case they click the 'Apply' button but don't actually apply
    @recommendation = current_main_passenger.card_accounts.where(
      status: %i[recommended applied]
    ).find(params[:id])

    # We can't know for sure if the user has actually applied; the most
    # we can do is note that they've visited this page and (hopefully)
    # been redirected to the bank's page
    @recommendation.applied!

    @card = @recommendation.card
    # TODO make the actual redirection work!
  end

  def decline
    raise "decline message must be present" unless decline_reason.present?

    @recommendation = get_card_recommendation
    @recommendation.decline_with_reason!(decline_reason)
    flash[:success] = t("admin.passengers.card_accounts.you_have_declined")
    redirect_to card_accounts_path
  end

  def open
    @account = get_card_account
    @account.open!
    flash[:success] = "Account opened" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  def deny
    @account = get_card_account
    @account.denied!
    flash[:success] = "Application denied" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  private

  def get_card_account
    current_main_passenger.card_accounts.find(params[:id])
  end

  def get_card_recommendation
    current_main_passenger.card_recommendations.find(params[:id])
  end

  def decline_reason
    params[:card_account][:decline_reason]
  end

end
