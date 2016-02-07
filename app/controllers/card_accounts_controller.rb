class CardAccountsController < NonAdminController
  helper CardAccountButtons

  before_action :user_must_have_completed_personal_and_spending_info_survey!,
    only: [:survey, :save_survey]

  def index
    @card_accounts = current_user\
                      .card_accounts.includes(:card).order(:created_at)
  end

  def survey
    @cards = Card.all
  end

  def save_survey
    cards = Card.where(id: params[:card_account][:card_ids])
    ActiveRecord::Base.transaction do
      CardAccount.unknown.create!(
        cards.map do |card|
          { user: current_user, card: card}
        end
      )
      current_user.info.update_attributes!(has_completed_card_survey: true)
    end
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

  def user_must_have_completed_personal_and_spending_info_survey!
    unless current_user.info.present?
      redirect_to survey_path
    end
  end

end
