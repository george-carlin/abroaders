class CardAccountsController < AuthenticatedUserController

  def index
    @people = current_account.people
    @card_recommendations = current_account.card_recommendations\
                              .includes(:card, offer: { card: :currency })\
                              .visible
    @card_accounts_from_survey = current_account.card_accounts.from_survey
    if current_account.card_recommendations.unresolved.count > 0
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    @recommendation_notes = current_account.recommendation_notes

    current_account.card_recommendations.unseen.update_all(seen_at: Time.now)
  end


  def survey
    @person = load_person
    @survey = CardsSurvey.new(person: @person)
  end

  def save_survey
    @person = load_person
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardsSurvey.new(survey_params.merge(person: @person)).save!
    track_intercom_event("obs_cards_#{@person.type[0..2]}")
    redirect_to current_account.onboarding_survey.current_page.path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  # WARNING non-strong-parameters hackery
  def survey_params
    if params[:cards_survey]
      { card_accounts: params[:cards_survey][:card_accounts] }
    else # if they clicked 'I don't have any cards'
      {}
    end
  end


end
