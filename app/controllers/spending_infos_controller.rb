class SpendingInfosController < AuthenticatedUserController
  onboard :spending, with: [:survey, :save_survey]

  def survey
    @form = SpendingSurvey.new(account: current_account)
    # fake a real TRB result until we've extracted things to an op
    warn "#{self.class}##{__method__} needs updating to use a TRB operation"
    @_result = {
      'account' => current_account,
      'values_remove_me' => @values,
      'contract.default' => @form,
      'eligible_people' => current_account.people.select(&:eligible?),
      'render_jsx' => true,
    }
    render cell(SpendingInfo::Cell::Survey, @_result)
  end

  def save_survey
    warn "#{self.class}##{__method__} needs updating to use a TRB operation"
    @form = SpendingSurvey.new(account: current_account)
    if @form.update_attributes(spending_survey_params)
      redirect_to onboarding_survey_path
    else
      # fake a real TRB result until we've extracted things to an op
      @_result = {
        'account' => current_account,
        'values_remove_me' => @values,
        'contract.default' => @form,
        'eligible_people' => current_account.people.select(&:eligible?),
        'render_jsx' => true,
      }
      render cell(SpendingInfo::Cell::Survey, @_result)
    end
  end

  def edit
    warn "#{self.class}##{__method__} needs updating to use a TRB operation"
    @person = load_person
    @spending_info = EditSpendingInfoForm.load(@person)
  end

  def update
    warn "#{self.class}##{__method__} needs updating to use a TRB operation"
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
    params.require(:spending_info).permit(
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
