class CardAccountsController < NonAdminController
  helper CardAccountButtons

  def index
    @card_accounts = current_user.card_accounts.order(:created_at)
  end

  def survey
    @cards = Card.all
  end

  def save_survey
    cards = Card.where(id: params[:card_account][:card_ids])
    CardAccount.unknown.create!(
      cards.map do |card|
        { user: current_user, card: card}
      end
    )
    redirect_to root_path
  end

  def apply
    @recommendation = get_card_account
    @card = @recommendation.card
  end

  def decline
    @recommendation = get_card_account
    @recommendation.decline!
    flash[:success] = t("admin.users.card_accounts.you_have_declined")
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
    current_user.card_accounts.find(params[:id])
  end

end
