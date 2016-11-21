module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      @person        = load_person
      @spending_info = @person.spending_info
      @account       = @person.account
      @travel_plans  = @account.travel_plans.includes_destinations
      @balances      = @person.balances.includes(:currency)

      card_account_scope = @person.card_accounts.includes(product: :bank, offer: :product)
      @card_accounts = card_account_scope.unpulled
      @pulled_card_accounts = card_account_scope.pulled
      @card_recommendation  = card_account_scope.recommendations.build

      @offers_grouped_by_product = \
        Offer.includes(:product, product: :currency).live.group_by(&:product)
      @recommendation_notes = @account.recommendation_notes
    end

    private

    def load_person
      Person.includes(:spending_info).find(params[:id])
    end
  end
end
