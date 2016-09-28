module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      @person        = load_person
      @account       = @person.account
      @travel_plans  = @account.travel_plans.includes_destinations
      @balances      = @person.balances.includes(:currency)
      @account_json  = AccountSerializer
                           .new(@account)
                           .to_json(include: { people: :spending_info })

      card_account_scope = @person.card_accounts.includes(:card, offer: :card)
      @card_accounts = card_account_scope.unpulled
      @pulled_card_accounts = card_account_scope.pulled
      @card_recommendation  = card_account_scope.recommendations.build

      @offers_grouped_by_card = \
        Offer.includes(:card, card: :currency).live.group_by(&:card)
      @recommendation_notes = @account.recommendation_notes
    end

    private

    def load_person
      Person.includes(account: [people: :spending_info]).find(params[:id])
    end
  end
end
