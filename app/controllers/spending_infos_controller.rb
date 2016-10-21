class SpendingInfosController < AuthenticatedUserController
  onboard :spending, with: [:survey, :save_survey]

  def survey
    @survey = SpendingSurvey.new(account: current_account)
  end

  def save_survey
    @survey = SpendingSurvey.new(account: current_account)
    if @survey.update_attributes(spending_survey_params)
      # track_intercom_event("obs_spending_#{type}")
      redirect_to onboarding_survey_path
    else
      render :survey
    end
  end

  def edit
    @person = load_person
    @spending_info = EditSpendingInfoForm.load(@person)
  end

  def update
    @person = load_person
    @spending_info = EditSpendingInfoForm.load(@person)
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
      :will_apply_for_loan,
    )
  end

  def spending_survey_params
    params.require(:spending_survey).permit(
      :monthly_spending,
      :companion_business_spending_usd,
      :companion_credit_score,
      :companion_has_business,
      :companion_will_apply_for_loan,
      :owner_business_spending_usd,
      :owner_credit_score,
      :owner_has_business,
      :owner_will_apply_for_loan,
    )
  end
end
