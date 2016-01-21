class CardAccountsController < NonAdminController

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

end
