class SurveyController < NonAdminController
  before_action { redirect_to root_path if current_account.onboarded? }

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
    @cards = SurveyCard.all
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
        redirect_to survey_balances_path(:main)
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
    @survey = BalancesSurvey.new(passenger)
    if @survey.update_attributes(balances_params)
      if params[:passenger] == "main" && has_companion?
        redirect_to survey_balances_path(:companion)
      else
        redirect_to survey_readiness_path
      end
    else
      @name  = load_name(params[:passenger])
      render "new_balances"
    end
  end

  def new_readiness
    @survey = ReadinessSurvey.new(current_account)
    if has_companion?
      @mp_name = Name.new(current_main_passenger.first_name)
      @co_name = Name.new(current_companion.first_name)
    else
      @mp_name = Name.you
    end
  end

  def create_readiness
    @survey = ReadinessSurvey.new(current_account)
    @survey.update_attributes!(readiness_survey_params)
    redirect_to root_path
  end

  private

  def balances_params
    params.permit(balances: [:currency_id, :value]).fetch(:balances, [])
  end

  def passenger_survey_params
    params.require(:passenger_survey).permit(
      :companion_citizenship, :companion_first_name, :companion_imessage,
      :companion_phone_number,
      :companion_text_message, :companion_whatsapp,
      :companion_willing_to_apply, :has_companion, :main_passenger_citizenship,
      :main_passenger_first_name, :main_passenger_imessage,
      :main_passenger_phone_number, :main_passenger_text_message,
      :main_passenger_whatsapp, :main_passenger_willing_to_apply,
      :shares_expenses,
    )
  end

  def spending_survey_params
    params.require(:spending_survey).permit(
      :companion_business_spending,
      :companion_credit_score,
      :companion_has_business,
      :companion_info,
      :companion_personal_spending,
      :companion_will_apply_for_loan,
      :main_passenger_business_spending,
      :main_passenger_credit_score,
      :main_passenger_has_business,
      :main_passenger_personal_spending,
      :main_passenger_will_apply_for_loan,
      :shared_spending
    )
  end

  def card_survey_params
    { card_ids: params[:card_account][:card_ids] }
  end

  def card_account_passenger_path
    case current_account.onboarding_stage
    when "main_passenger_cards"
      survey_card_accounts_path(:main)
    when "companion_cards"
      survey_card_accounts_path(:companion)
    else raise "this should never happen"
    end
  end

  def balances_passenger_path
    case current_account.onboarding_stage
    when "main_passenger_balances"
      survey_balances_path(:main)
    when "companion_balances"
      survey_balances_path(:companion)
    else raise "this should never happen"
    end
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

  def readiness_survey_params
    params.require(:readiness_survey).permit(
      :main_passenger_ready, :main_passenger_unreadiness_reason,
      :companion_ready,      :companion_unreadiness_reason
    )
  end

end
