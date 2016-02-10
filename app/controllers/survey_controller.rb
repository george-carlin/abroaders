class SurveyController < NonAdminController
  def user_info
    @user_info = current_user.build_info
  end

  def create_user_info
    @user_info = current_user.build_info(user_info_params)
    if @user_info.save
      redirect_to survey_card_accounts_path
    else
      render "user_info"
    end
  end

  def card_accounts
    @cards = Card.all
  end

  def create_card_accounts
    cards = Card.where(id: params[:card_account][:card_ids])
    ActiveRecord::Base.transaction do
      CardAccount.unknown.create!(
        cards.map do |card|
          { user: current_user, card: card}
        end
      )
      current_user.info.update_attributes!(has_completed_card_survey: true)
    end
    redirect_to survey_balances_path
  end

  def balances
    @currencies = Currency.all
  end

  # TODO this needs better error handling
  def create_balances
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }
    ApplicationRecord.transaction do
      current_user.balances.create!(balances_params)
      current_user.info.update_attributes!(has_completed_balances_survey: true)
    end
    redirect_to root_path
  end

  private

  def balances_params
    params.permit(balances: [:currency_id, :value])[:balances] || []
  end

  def user_info_params
    params.require(:user_info).permit(
      :first_name, :middle_names, :last_name, :whatsapp, :imessage, :time_zone,
      :text_message, :phone_number, :credit_score, :business_spending,
      :will_apply_for_loan, :personal_spending, :has_business, :citizenship
    )
  end

end
