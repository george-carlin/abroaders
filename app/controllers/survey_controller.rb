class SurveyController < NonAdminController
  before_action { redirect_to root_path if current_account.survey_complete? }

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
    if @survey.update_attributes(spending_survey_params)
      redirect_to survey_card_accounts_path
    else
      render "new_spending"
    end
  end

  def new_card_accounts
    redirect_to card_account_passenger_path and return unless params[:passenger]
    @name  = load_name(params[:passenger])
    @cards = Card.all
  end

  def create_card_accounts
    @survey = case params[:passenger]
              when "main"      then CardsSurvey.new(current_main_passenger)
              when "companion" then CardsSurvey.new(current_companion)
              end
    if @survey.update_attributes(card_survey_params)
      if params[:passenger] == "main" && has_companion?
        redirect_to survey_card_accounts_path(:companion)
      else
        redirect_to survey_balances_path
      end
    else
      # As it stands, there's no way the user can submit the existing
      # survey in a way that would fail validations.
      raise "this should never happen"
    end
  end

  def new_balances
    redirect_to balances_passenger_path and return unless params[:passenger]
    @survey = case params[:passenger]
              when "main"      then BalancesSurvey.new(current_main_passenger)
              when "companion" then BalancesSurvey.new(current_companion)
              end
    @name  = load_name(params[:passenger])
  end

  def create_balances
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }
    passenger = case params[:passenger]
                when "main"      then current_main_passenger
                when "companion" then current_companion
                end
    @survey = BalancesSurvey.new(passenger, balances_params)
    if @survey.save
      if params[:passenger] == "main" && has_companion?
        redirect_to survey_card_accounts_path(:companion)
      else
        # TODO redirect to travel plan form when it's ready
        redirect_to root_path
      end
    else
      @name  = load_name(params[:passenger])
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

  def spending_survey_params
    params.require(:spending_survey).permit(
      :companion_info_business_spending,
      :companion_info_credit_score,
      :companion_info_has_business,
      :companion_info_info,
      :companion_info_personal_spending,
      :companion_info_will_apply_for_loan,
      :main_info_business_spending,
      :main_info_credit_score,
      :main_info_has_business,
      :main_info_personal_spending,
      :main_info_will_apply_for_loan
    )
  end

  def card_survey_params
    { card_ids: params[:card_account][:card_ids] }
  end

  def card_account_passenger_path
    account = current_account # for the sake of short lines
    if account.main_passenger.has_added_cards?
      if account.has_companion? && !account.companion.has_added_cards?
        result = survey_card_accounts_path(:companion)
      else
        raise "this should never happen"
      end
    else
      result = survey_card_accounts_path(:main)
    end
    result
  end

  def balances_passenger_path
    account = current_account # for the sake of short lines
    if account.main_passenger.has_added_balances?
      if account.has_companion? && !account.companion.has_added_balances?
        result = survey_balances_path(:companion)
      else
        raise "this should never happen"
      end
    else
      result = survey_balances_path(:main)
    end
    result
  end

  def load_name(passenger_type)
    if passenger_type == "main"
      if has_companion?
        Name.new(current_main_passenger.first_name)
      else
        Name.you
      end
    else
      Name.new(current_companion.first_name)
    end
  end

end
