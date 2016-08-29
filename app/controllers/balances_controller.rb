class BalancesController < AuthenticatedUserController
  include EventTracking

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
    @valid   = @balance.update(update_balance_params)
    respond_to do |f|
      f.js
    end
  end

  def survey
    @person = load_person
    @survey = BalancesSurvey.new(@person)
  end

  def save_survey
    @person = load_person
    @survey = BalancesSurvey.new(@person)
    # Bleeargh technical debt
    @survey.assign_attributes(survey_params)
    @survey.award_wallet_email = params[:balances_survey_award_wallet_email]
    if @survey.save
      onboarding_survey = current_account.onboarding_survey
      if onboarding_survey.complete?
        AccountMailer.notify_admin_of_survey_completion(
          current_account.id, Time.now.to_i
        ).deliver_later
      end
      track_intercom_event("obs_balances_#{@person.type[0..2]}")
      redirect_to onboarding_survey.current_page.path
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

end
