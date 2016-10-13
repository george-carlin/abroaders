class SpendingInfosController < AuthenticatedUserController
  skip_before_action :redirect_if_onboarding_survey_incomplete!, only: [:update]

  def new
    redirect_if_inaccessible! and return
    @spending_info = SpendingSurvey.new(person: @person)
  end

  def create
    @person = load_person
    redirect_if_inaccessible! and return
    @spending_info = SpendingSurvey.new(person: @person)
    if @spending_info.update_attributes(spending_survey_params)
      current_account.save!
      type = @person.type[0..2]
      track_intercom_event("obs_spending_#{type}")
      track_intercom_event("obs_#{"un" unless @person.ready?}ready_#{type}")
      redirect_to survey_person_card_accounts_path(@person)
    else
      render :new
    end
  end

  def edit
    @person = load_person
    @spending_info = EditSpendingInfoForm.find(@person)
  end

  def update
    @person = load_person
    @spending_info = EditSpendingInfoForm.find(@person)
    if @spending_info.update(spending_info_params)
      flash[:success] = "Updated spending info"
      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def spending_info_params
    params.require(:spending_info).permit(
      :monthly_spending_usd,
      :business_spending_usd,
      :credit_score,
      :has_business,
      :will_apply_for_loan
    )
  end

  def spending_survey_params
    params.require(:spending_info).permit(
      :business_spending_usd,
      :credit_score,
      :has_business,
      :will_apply_for_loan,
      :unreadiness_reason,
      :ready
    )
  end

  def redirect_if_inaccessible!
    # TODO update me to use the new OnboardingSurvey system
    # if !@person.eligible?
    #   redirect_to survey_person_balances_path(@person) and return true
    # elsif @person.onboarded_spending?
    #   redirect_to survey_person_card_accounts_path(@person) and return true
    # end
  end
end
