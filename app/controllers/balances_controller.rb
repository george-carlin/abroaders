class BalancesController < AuthenticatedUserController
  before_action :redirect_if_not_onboarded_travel_plans!
  before_action :redirect_if_account_type_not_selected!

  def index
    @people = current_account.people.includes(balances: :currency)
  end

  def new
    @person  = current_account.people.find(params[:person_id])
    @balance = @person.balances.build
  end

  def create
    @person  = current_account.people.find(params[:person_id])
    @balance = NewBalanceForm.new(create_balance_params(@person))
    if @balance.save
      redirect_to balances_path
    else
      render "new"
    end
  end

  def update
    @balance = EditBalanceForm.new(current_account.balances.find(params[:id]).attributes)
    @value   = @balance.update(update_balance_params)
    respond_to do |f|
      f.js
    end
  end

  def survey
    @person = load_person
    redirect_if_already_completed_survey! and return
    @survey = BalancesSurvey.new(@person)
  end

  def save_survey
    @person = load_person
    redirect_if_already_completed_survey! and return
    @survey = BalancesSurvey.new(@person)
    # Bleeargh technical debt
    @survey.assign_attributes(survey_params)
    @survey.award_wallet_email = params[:balances_survey_award_wallet_email]
    if @survey.save
      redirect_to after_save_path
    else
      render "survey"
    end
  end

  private

  def create_balance_params(person)
    # Virtus will call `to_hash` on the passed attributes, but this method
    # is deprecated on ActionController::Parameters; call `to_h` instead:
    params.require(:balance).permit(:value, :currency_id).merge(person: person).to_h
  end

  def update_balance_params
    params.require(:balance).permit(:value)
  end

  def survey_params
    params.permit(
      balances: [:currency_id, :value]
    ).fetch(:balances, [])
  end

  def load_person
    current_account.people.find(params[:person_id])
  end

  def redirect_if_already_completed_survey!
    if @person.onboarded_balances?
      redirect_to root_path and return true
    end
  end

  def after_save_path
    if @person.eligible?
      new_person_readiness_path(@person)
    elsif !@person.main? || !(partner = current_account.companion)
      root_path
    elsif partner.eligible?
      new_person_spending_info_path(partner)
    else
      survey_person_balances_path(partner)
    end
  end
end
