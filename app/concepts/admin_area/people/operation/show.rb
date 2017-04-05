module AdminArea
  module People
    module Operation
      # param:
      #   id: the person's ID
      class Show < Trailblazer::Operation
        step :load_person!
        step :set_account!
        step :set_balances!
        step :set_home_airports!
        step :set_offers!
        step :set_recommendation_notes!
        step :set_regions_of_interest!
        step :set_travel_plans!

        private

        def load_person!(opts, params:, **)
          opts['person'] = Person.includes(
            unpulled_cards: { product: :bank },
          ).find(params[:id])
        end

        def set_account!(opts, person:, **)
          opts['account'] = person.account
        end

        def set_balances!(opts, person:, **)
          opts['balances'] = person.balances.includes(:currency)
        end

        def set_home_airports!(opts, account:, **)
          opts['home_airports'] = account.home_airports
        end

        def set_offers!(opts)
          opts['offers'] = Offer.includes(product: [:bank, :currency]).live
        end

        def set_recommendation_notes!(opts, account:, **)
          opts['recommendation_notes'] = \
            account.recommendation_notes.order(created_at: :desc)
        end

        def set_regions_of_interest!(opts, account:, **)
          opts['regions_of_interest'] = account.regions_of_interest
        end

        def set_travel_plans!(opts, account:, **)
          opts['travel_plans'] = account.travel_plans.includes_destinations
        end
      end
    end
  end
end
