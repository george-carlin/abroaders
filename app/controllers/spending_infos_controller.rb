class SpendingInfosController < AuthenticatedUserController
  def new
    @person = load_person
    @name = name_object(@person)
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
      track_intercom_event("obs_#{"un" if !@person.ready?}ready_#{type}")
      redirect_to survey_person_card_accounts_path(@person)
    else
      @name = name_object(@person)
      render "new"
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def name_object(person)
    current_account.has_companion? ? Name.new(person.first_name) : Name.new("you")
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
    if !@person.eligible?
      redirect_to survey_person_balances_path(@person) and return true
    elsif @person.onboarded_spending?
      redirect_to survey_person_card_accounts_path(@person) and return true
    end
  end

end
