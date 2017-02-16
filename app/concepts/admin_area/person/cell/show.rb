require 'abroaders/cell/options'

module AdminArea
  module Person
    module Cell
      # placeholder class; eventually the whole template should be moved in here
      #
      # @!method self.call(result, opts = {})
      #   @param result [Result] result of AdminArea::People::Operation::Show
      #   @option result [Account] account
      #   @option result [Collection<Balance>] balances
      #   @option result [Collection<Airport>] home_airports
      #   @option result [Collection<Offer>] offers the recommendable offers
      #   @option result [Person] person
      #   @option result [Collection<Region>] regions_of_interest
      class Show < Trailblazer::Cell
        alias result model

        def balances
          collection = result['balances']
          cell(AdminArea::Person::Cell::Balances, person, balances: collection)
        end

        def cards
          cell(
            AdminArea::Person::Cell::Show::Cards,
            result['cards'],
            person: person,
            pulled_recs: result['pulled_recs'],
          )
        end

        # TODO once this cell is being used in the proper way, these methods
        # should all be made private

        # If the account has any home airports, list them.
        # Else display text saying there are no home airports.
        def home_airports
          if result['home_airports'].any?
            raw(
              '<h3>Home Airports</h3>' +
              cell(HomeAirports::Cell::List, result['home_airports']).(),
            )
          else
            'User has not added any home airports'
          end
        end

        # list the offers that can be recommended to the current user, grouped
        # by their product
        def recommendable_offers
          cell(RecommendationTable, person, offers: result['offers'])
        end

        def recommendation_notes
          cell(RecommendationNotes, result['recommendation_notes'])
        end

        # If the account has any ROIs,  list them.
        # Else display text saying there are no ROIs.
        def regions_of_interest
          if result['regions_of_interest'].any?
            raw(
              '<h3>Regions of Interest</h3>' +
              cell(RegionsOfInterest::Cell::List, result['regions_of_interest']).(),
            )
          else
            'User has not added any regions of interest'
          end
        end

        def spending_info
          cell(AdminArea::Person::Cell::SpendingInfo, person, account: account)
        end

        def travel_plans
          collection = result['travel_plans']
          return 'User has no upcoming travel plans' if collection.none?
          plans = content_tag :div, class: 'account_travel_plans' do
            cell(
              TravelPlan::Cell::Summary,
              collection: collection,
              editable: false,
            )
          end
          # using 'raw' all over the place is not ideal :(
          raw('<h3>Travel Plans</h3>' << plans)
        end

        private

        def account
          result['account']
        end

        def person
          result['person']
        end

        # the <table> of available products and offers that can be recommended.
        #
        # @!method self.call(person, opts = {})
        #   @param person [Person]
        #   @option opts [Collection<Offer>] the recommendable offers. Be wary
        #     of n+1 issues, as this cell will read the offers' products, and
        #     the banks and currencies of those products.
        class RecommendationTable < Trailblazer::Cell
          extend Abroaders::Cell::Options

          alias person model

          option :offers

          private

          def offers_grouped_by_product
            @_ogbp ||= offers.group_by(&:product)
          end
        end
      end
    end
  end
end
