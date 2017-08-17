class CardsController < AuthenticatedUserController
  onboard :owner_cards, :companion_cards, with: [:survey, :save_survey]

  def index
    # Unfortunately I can't figure out a better way of avoiding all the N+1 issues
    # without reloading the current account, since you can't call `includes`
    # after the account has already been loaded.
    account = Account.includes(
      people: [:account, { card_accounts: :card_product },
               actionable_card_recommendations: [:card_product, { offer: { card_product: :currency } }],],
    ).find(current_account.id)
    if account.actionable_card_recommendations?
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    unless current_admin
      account.card_recommendations.unseen.update_all(seen_at: Time.zone.now)
    end

    render cell(Card::Cell::Index, account)
  end

  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return
    redirect_if_onboarding_wrong_person_type! && true
    form = Card::Survey.new(@person)
    render cell(Card::Cell::Survey, @person, form: form)
  end

  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return
    form = Card::Survey.new(@person)
    if form.validate(survey_params)
      # There's currently no way that survey_params can be invalid
      form.save
      redirect_to onboarding_survey_path
    else
      raise 'this should never happen!'
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def survey_params
    # key will be nil if they clicked 'I don't have any cards'
    result = params[:cards_survey] || { cards: [] }
    # couldn't figure out how to filter out unopened cards from within the form
    # object, so I'm doing it at the controller level
    result[:cards].select! { |c| Types::Form::Bool.(c[:opened]) }
    result
  end
end
