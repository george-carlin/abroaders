class CardsController < AuthenticatedUserController
  onboard :owner_cards, :companion_cards, with: [:survey, :save_survey]

  def index
    @people = current_account.people
    @recommendations = current_account.card_recommendations\
                                      .includes(:product, offer: { product: :currency })\
                                      .visible
    @cards = current_account.cards.non_recommendation.includes(:product, :offer)
    if current_account.card_recommendations.unresolved.count > 0
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    # admins can't edit notes, so our crude way of allowing it for now
    # is to let admins submit a new updated note, and we only ever show
    # the most recent note to the user:
    @newest_rec_note = current_account.recommendation_notes.order(created_at: :desc).first

    current_account.card_recommendations.unseen.each do |c|
      c.update!(seen_at: Time.zone.now)
    end
  end

  # GET /cards/new
  # GET /products/:product_id/cards/new
  def new
    if params[:product_id]
      run Card::Operation::New
      render cell(Card::Cell::New, result)
    else
      run Card::Operation::New::SelectProduct
      # TODO pass result to the cell directly
      render cell(Card::Cell::New::SelectProduct, @collection, banks: result['banks'])
    end
  end

  def create
    run Card::Operation::Create do
      flash[:success] = 'Added card!'
      redirect_to cards_path
      return
    end
    render cell(Card::Cell::New, result)
  end

  def edit
    run Card::Operation::Edit
    @form.prepopulate!
  end

  def update
    run Card::Operation::Update do
      flash[:success] = 'Updated card'
      return redirect_to cards_path
    end
    render :edit
  end

  def destroy
    run Card::Operation::Destroy do
      flash[:success] = 'Removed card'
      return redirect_to cards_path
    end
    raise 'this should never happen'
  end

  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    @survey = CardProduct::Survey.new(person: @person)
  end

  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardProduct::Survey.new(survey_params.merge(person: @person)).save!
    # track_intercom_event("obs_cards_#{@person.type[0..2]}")
    redirect_to onboarding_survey_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def survey_params
    if params.key?(:cards_survey)
      params.require(:cards_survey).permit(cards: [:product_id, :opened, :closed, :opened_at_, :closed_at_])
    else # if they clicked 'I don't have any cards'
      {}
    end
  end
end
