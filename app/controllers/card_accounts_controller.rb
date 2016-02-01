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

  private

  def get_card_account
    current_user.card_accounts.find(params[:id])
  end

end
