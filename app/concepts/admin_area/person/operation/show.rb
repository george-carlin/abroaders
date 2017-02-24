module AdminArea
  module Person
    module Operation
      # param:
      #   id: the person's ID
      class Show < Trailblazer::Operation
        step :load_person!
        step :set_account!
        step :set_balances!
        step :set_card_scope!
        step :set_cards!
        step :set_home_airports!
        step :set_offers!
        step :set_recommendation_notes!
        step :set_regions_of_interest!
        step :set_pulled_recs!
        step :set_travel_plans!

        private

        def load_person!(opts, params:, **)
          opts['person'] = ::Person.includes(:spending_info).find(params[:id])
        end

        def set_account!(opts, person:, **)
          opts['account'] = person.account
        end

        def set_balances!(opts, person:, **)
          opts['balances'] = person.balances.includes(:currency)
        end

        def set_card_scope!(opts, person:, **)
          # save this here so that we don't have to make the same 'includes'
          # calls in multiple steps:
          opts['cards.scope'] = person.cards.includes(product: :bank, offer: :product)
        end

        def set_cards!(opts, **)
          opts['cards'] = opts['cards.scope'].unpulled
        end

        def set_home_airports!(opts, account:, **)
          opts['home_airports'] = account.home_airports
        end

        def set_offers!(opts)
          opts['offers'] = Offer.includes(product: [:bank, :currency]).live
        end

        def set_pulled_recs!(opts)
          opts['pulled_recs'] = opts['cards.scope'].recommendations.pulled
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
