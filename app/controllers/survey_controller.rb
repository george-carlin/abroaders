class SurveyController < NonAdminController
  before_action { redirect_to root_path if current_account.onboarded? }


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
