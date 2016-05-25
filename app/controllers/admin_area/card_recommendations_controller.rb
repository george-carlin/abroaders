module AdminArea
  class CardRecommendationsController < AdminController
    before_action :set_person
    before_action :person_must_be_onboarded!

    def new
      @account       = @person.account
      @spending_info = @person.spending_info
      accounts_scope = @person.card_accounts.includes(:card, offer: :card)
      @cards_from_survey    = accounts_scope.from_survey
      # Call 'to_a' so it doesn't include @card_recommendation:
      @card_recommendations = accounts_scope.recommendations.to_a
      @card_recommendation  = accounts_scope.recommendations.build
      @offers_grouped_by_card = \
        Offer.includes(:card, card: :currency).live.group_by(&:card)
      @balances     = @person.balances.includes(:currency)
      @travel_plans = @account.travel_plans.includes_destinations
    end

    def create
      # TODO don't allow expired/inactive offers to be assigned:
      offer = Offer.find(params[:offer_id])
      @person.card_recommendations.create!(offer: offer, recommended_at: Time.now)
      flash[:success] = "Recommended card!"
      # TODO notify person
      redirect_to new_admin_person_card_recommendation_path(@person)
    end

    def complete
      CompleteCardRecommendations.new(@person).complete!
      flash[:success] = "Sent notification!"
      redirect_to new_admin_person_card_recommendation_path(@person)
    end

    private

    def set_person
      @person = Person.find(params[:person_id])
    end

    def person_must_be_onboarded!
      unless @person.onboarded?
        flash[:error] = t("admin.people.card_recommendations.not_onboarded")
        redirect_to admin_person_path(@person)
      end
    end

  end
end
