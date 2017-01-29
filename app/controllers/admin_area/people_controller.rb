# temporary hack
require 'admin_area'
require 'admin_area/cells'
require 'admin_area/cells/people/show'
require 'admin_area/cells/regions_of_interest/list'
require 'admin_area/cells/home_airports/list'

module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      @person        = load_person
      @spending_info = @person.spending_info
      @account       = @person.account
      @travel_plans  = @account.travel_plans.includes_destinations
      @balances      = @person.balances.includes(:currency)

      card_scope = @person.cards.includes(product: :bank, offer: :product)
      @cards     = card_scope.unpulled
      @pulled_cards   = card_scope.pulled
      @recommendation = card_scope.recommendations.build

      @offers_grouped_by_product = \
        Offer.includes(product: [:bank, :currency]).live.group_by(&:product)
      @recommendation_notes = @account.recommendation_notes
    end

    private

    def load_person
      ::Person.includes(:spending_info).find(params[:id])
    end
  end
end
