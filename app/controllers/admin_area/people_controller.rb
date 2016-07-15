module AdminArea
  class PeopleController < AdminController

    # GET /admin/people/1
    def show
      @person        = load_person
      @spending_info = @person.spending_info
      @account       = @person.account
      @travel_plans  = @account.travel_plans.includes_destinations
      @balances      = @person.balances.includes(:currency)
      accounts_scope = @person.card_accounts.includes(:card, offer: :card)
      @cards_from_survey    = accounts_scope.from_survey
      @card_recommendations = accounts_scope.recommendations
      @card_recommendation  = accounts_scope.recommendations.build
      @offers_grouped_by_card = \
        Offer.includes(:card, card: :currency).live.group_by(&:card)
      @recommendation_notes = @account.recommendation_notes
    end

    private

    def load_person
      Person.find(params[:id])
    end

  end
end
