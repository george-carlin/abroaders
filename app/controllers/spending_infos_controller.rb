class SpendingInfosController < AuthenticatedUserController
  onboard :spending, with: [:survey, :save_survey]

  def show
    run SpendingInfo::Show do
      account = Account.includes(
        eligible_people: { spending_info: { person: :account } },
      ).find(current_account.id)
      render cell(SpendingInfo::Cell::Show, account)
      return
    end
    redirect_to root_path
  end

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
    @model = load_person.spending_info
    @form  = SpendingInfo::Form.new(@model)
  end

  def update
    @model = load_person.spending_info
    @form  = SpendingInfo::Form.new(@model)
    if @form.validate(params[:spending_info])
      @form.save
      flash[:success] = 'Updated spending info'
      redirect_to root_path
    else
      render :edit
    end
  end

  def confirm
    @model = load_person.spending_info
    @form  = SpendingInfo::Form.new(@model)
    if @form.validate(params[:spending_info])
      @form.save
      @valid = true
    end
    respond_to(&:js)
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
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
