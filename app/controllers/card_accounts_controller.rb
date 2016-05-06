class CardAccountsController < NonAdminController
  # TODO is this being used?
  helper CardAccountButtons

  before_action :redirect_if_not_onboarded_travel_plans!,
                                      only: [:survey, :save_survey]
  before_action :redirect_if_account_type_not_selected!,
                                      only: [:survey, :save_survey]

  def index
  end

  def survey
    @person = load_person
    redirect_if_survey_is_inaccessible! and true
    @survey = CardsSurvey.new(person: @person)
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
    @recommendation = current_account.card_accounts.find(params[:id])

    # Make sure this is the right type of card account:
    redirect_to card_accounts_path and return unless @recommendation.recommendation?

    # We can't know for sure if the user has actually applied; the most
    # we can do is note that they've visited this page and (hopefully)
    # been redirected to the bank's page
    @recommendation.clicked!
    @card = @recommendation.card
  end

  def decline
    raise "decline message must be present" unless decline_reason.present?

    if @recommendation = load_card_recommendation
      @recommendation.decline_with_reason!(decline_reason)
      flash[:success] = t("admin.passengers.card_accounts.you_have_declined")
      redirect_to card_accounts_path
    else
      flash[:info] = t("card_accounts.index.couldnt_decline")
      redirect_to card_accounts_path
    end
  end

  def open
    @account = load_card_account
    @account.open!
    flash[:success] = "Account opened" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  def deny
    @account = load_card_account
    @account.denied!
    flash[:success] = "Application denied" # TODO give this a better message!
    # TODO also need to let the user say *when* the card was opened
    # TODO redirect to the card's individual page once we've added them.
    redirect_to card_accounts_path
  end

  private

  def load_card_account
    current_main_passenger.card_accounts.find(params[:id])
  end

  def load_card_recommendation
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
