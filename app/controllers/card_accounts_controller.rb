class CardAccountsController < NonAdminController

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

  def decline
    @recommendation = current_user.card_accounts.find(params[:id])
    @recommendation.decline!
    flash[:success] = t("admin.users.card_accounts.you_have_declined")
    redirect_to card_accounts_path
  end

end
