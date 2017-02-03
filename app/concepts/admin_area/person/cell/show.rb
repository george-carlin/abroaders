module AdminArea
  module Person
    module Cell
      # placeholder class; eventually the whole template should be moved in here
      class Show < Trailblazer::Cell
        alias person model

        # TODO once this cell is being used in the proper way, these methods
        # should be made private

        # If the account has any ROIs,  list them.
        # Else display text saying there are no ROIs.
        def regions_of_interest
          if account.regions_of_interest.any?
            raw(
              '<h3>Regions of Interest</h3>' +
              cell(AdminArea::RegionsOfInterest::Cell::List, account.regions_of_interest).to_s,
            )
          else
            'User has not added any regions of interest'
          end
        end

        # If the account has any home airports, list them.
        # Else display text saying there are no home airports.
        def home_airports
          if account.home_airports.any?
            raw(
              '<h3>Home Airports</h3>' +
              cell(AdminArea::HomeAirports::Cell::List, account.home_airports).to_s,
            )
          else
            'User has not added any home airports'
          end
        end

        private

        def account
          @account ||= person.account
        end

        # the <table> of available products and offers that can be recommended.
        #
        # model: the Person
        # options:
        #   offers: the recommendable offers. Be wary of n+1 issues, as this
        #           cell will read the offers' products, and the banks and
        #           currencies of those products.
        class RecommendationTable < Trailblazer::Cell
          alias person model

          private

          def offers_grouped_by_product
            @_ogbp ||= options.fetch(:offers).group_by(&:product)
          end
        end
      end
    end
  end
end
