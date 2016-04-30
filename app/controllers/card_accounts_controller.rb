class CardAccountsController < NonAdminController
  helper CardAccountButtons

  before_action :redirect_if_not_onboarded_travel_plans!,
                                      only: [:survey, :save_survey]
  before_action :redirect_if_account_type_not_selected!,
                                      only: [:survey, :save_survey]

  def index
    scope = current_main_passenger\
                    .card_accounts.includes(:card).order(:created_at)
    @recommended_card_accounts = scope.recommended.load
    @unknown_card_accounts     = scope.unknown.load
    @applied_card_accounts     = scope.applied.load

    if has_companion?
      partner_scope = current_companion\
                        .card_accounts.includes(:card).order(:created_at)
      @p_recommended_card_accounts = partner_scope.recommended.load
      @p_unknown_card_accounts     = partner_scope.unknown.load
      @p_applied_card_accounts     = partner_scope.applied.load
    end

    @other_card_accounts = scope.where.not(
      id: [
        @recommended_card_accounts + @unknown_card_accounts + \
        @applied_card_accounts
      ]
    )
  end

  def survey
    @person = load_person
    redirect_if_survey_is_inaccessible! and true
    @survey = CardsSurvey.new(person: @person)# SurveyCard.all
  end

  def save_survey
    @person = load_person
    redirect_if_survey_is_inaccessible! and true
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardsSurvey.new(survey_params.merge(person: @person)).save!
    redirect_to survey_person_balances_path(@person)
  end

  def apply
    unless params[:person_id]
      account = CardAccount.find(params[:id])
      redirect_to apply_person_card_account_path(account.person, account) and return
    end

    # They should still be able to access this page if the card is 'applied',
    # in case they click the 'Apply' button but don't actually apply
    @recommendation = current_account.people.find(params[:person_id]).card_accounts.where(
      status: %i[recommended applied]
    ).find(params[:id])

    # We can't know for sure if the user has actually applied; the most
    # we can do is note that they've visited this page and (hopefully)
    # been redirected to the bank's page
    @recommendation.applied!

    @card = @recommendation.card
    # TODO make the actual redirection work!
  end

  def decline
    raise "decline message must be present" unless decline_reason.present?

    if @recommendation = get_card_recommendation
      @recommendation.decline_with_reason!(decline_reason)
      flash[:success] = t("admin.passengers.card_accounts.you_have_declined")
      redirect_to card_accounts_path
    else
      flash[:info] = t("card_accounts.index.couldnt_decline")
      redirect_to card_accounts_path
    end
  end

  def open
    @account = get_card_account
    @account.open!
    flash[:success] = "Account opened" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  def deny
    @account = get_card_account
    @account.denied!
    flash[:success] = "Application denied" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  private

  def get_card_account
    current_main_passenger.card_accounts.find(params[:id])
  end

  def get_card_recommendation
    current_main_passenger.card_recommendations.find_by(id: params[:id])
  end

  def decline_reason
    params[:card_account][:decline_reason]
  end

  def load_person
    current_account.people.find(params[:person_id])
  end

  # WARNING non-strong-parameters hackery
  def survey_params
    { card_accounts: params[:cards_survey][:card_accounts] }
  end

  def redirect_if_survey_is_inaccessible!
    if !@person.onboarded_spending?
      redirect_to new_person_spending_info_path(@person) and return true
    elsif !@person.eligible_to_apply? || @person.onboarded_cards?
      redirect_to survey_person_balances_path(@person) and return true
    end
  end


end
