class SurveyController < NonAdminController
  # SURVEYTODO uncomment me
  #before_action { redirect_to root_path if current_account.survey_complete? }

  def new_passengers
    @survey = PassengerSurvey.new(current_account)
  end

  def create_passengers
    @survey = PassengerSurvey.new(current_account)
    if @survey.update_attributes(passenger_survey_params)
      redirect_to survey_spending_path
    else
      render "new_passengers"
    end
  end

  def new_spending
    @survey = SpendingSurvey.new(current_account)
  end

  def create_spending
    @survey = SpendingSurvey.new(current_account)
    if @survey.save
      redirect_to survey_card_accounts_path
    else
      render "new_spending"
    end
  end

  def new_card_accounts
    @cards = Card.all
  end

  def create_card_accounts
    cards = Card.where(id: params[:card_account][:card_ids])
    ActiveRecord::Base.transaction do
      CardAccount.unknown.create!(
        cards.map do |card|
          { user: current_account, card: card}
        end
      )
      current_account.survey.update_attributes!(has_added_cards: true)
    end
    redirect_to survey_balances_path
  end

  def new_balances
    @survey = BalancesSurvey.new(current_account)
  end

  def create_balances
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }

    @survey = BalancesSurvey.new(current_account, balances_params)

    if @survey.save
      redirect_to root_path
    else
      render "new_balances"
    end
  end

  private

  def balances_params
    params.permit(balances: [:currency_id, :value]).fetch(:balances, [])
  end

  def passenger_survey_params
    params.require(:passenger_survey).permit(
      :companion_citizenship, :companion_first_name, :companion_imessage,
      :companion_last_name, :companion_middle_names, :companion_phone_number,
      :companion_text_message, :companion_whatsapp,
      :companion_willing_to_apply, :has_companion, :main_passenger_citizenship,
      :main_passenger_first_name, :main_passenger_imessage,
      :main_passenger_last_name, :main_passenger_middle_names,
      :main_passenger_phone_number, :main_passenger_text_message,
      :main_passenger_whatsapp, :main_passenger_willing_to_apply,
      :shares_expenses, :time_zone,
    )
  end

end
