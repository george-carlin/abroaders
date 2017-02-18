require 'abroaders/cell/options'
require 'abroaders/cell/result'

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
      #   @option result [Collection<Card>] cards
      #   @option result [Collection<Airport>] home_airports
      #   @option result [Collection<Offer>] offers the recommendable offers
      #   @option result [Person] person
      #   @option result [Collection<RecommendationNote>] recommendation_notes
      #   @option result [Collection<Region>] regions_of_interest
      #   @option result [Collection<TravelPlan>] travel_plans
      class Show < Trailblazer::Cell
        extend Abroaders::Cell::Result

        skill :account
        skill :offers
        skill :person
        skill :pulled_recs

        # the cell that renders an individual travel plan. Sticking it in a
        # class method like this so I can easily stub it when testing.  Still
        # haven't figured out the best way to handle DI in cells. FIXME
        def self.travel_plan_cell
          TravelPlan::Cell::Summary
        end

        def title
          person.first_name
        end

        private

        def award_wallet_email
          cell(AwardWalletEmail, person)
        end

        def balances
          collection = result['balances']
          cell(AdminArea::Person::Cell::Balances, person, balances: collection)
        end

        def bank_filter_panels
          cell(Bank::Cell::FilterPanel, Bank.order(name: :asc))
        end

        def card_bp_filter_check_box_tag(bp)
          klass =  :card_bp_filter
          id    =  :"#{klass}_#{bp}"
          label_tag id do
            check_box_tag(
              id,
              nil,
              true,
              class: klass,
              data: { key: :bp, value: bp },
            ) << raw("&nbsp;&nbsp#{bp.capitalize}")
          end
        end

        def cards
          cell(Cards, result['cards'], person: person, pulled_recs: pulled_recs)
        end

        def currency_filter_panels
          alliances = Alliance.in_order
          cell(Alliance::Cell::CurrencyFilterPanel, collection: alliances)
        end

        def heading
          cell(Heading, person, account: account)
        end

        # If the account has any home airports, list them.
        # Else display text saying there are no home airports.
        def home_airports
          if result['home_airports'].any?
            '<h3>Home Airports</h3>' +
              cell(HomeAirports::Cell::List, result['home_airports']).()
          else
            'User has not added any home airports'
          end
        end

        # list the offers that can be recommended to the current user, grouped
        # by their product
        def recommendable_offers
          cell(RecommendationTable, person, offers: offers)
        end

        def recommendation_notes
          cell(RecommendationNotes, result['recommendation_notes'])
        end

        # If the account has any ROIs,  list them.
        # Else display text saying there are no ROIs.
        def regions_of_interest
          if result['regions_of_interest'].any?
            '<h3>Regions of Interest</h3>' +
              cell(RegionsOfInterest::Cell::List, result['regions_of_interest']).()
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
            cell(self.class.travel_plan_cell, collection: collection, editable: false)
          end
          '<h3>Travel Plans</h3>' << plans
        end

        # @param model [Person]
        class AwardWalletEmail < Trailblazer::Cell
          include Escaped

          property :award_wallet_email

          def show
            return '' if award_wallet_email.nil?
            "<p><b>AwardWallet email:</b> #{award_wallet_email}</p>"
          end
        end

        # @!method self.call(person, opts = {})
        #   @param person [Person]
        #   @option opts [Account] account
        class Heading < Trailblazer::Cell
          extend Abroaders::Cell::Options
          include Escaped

          property :first_name

          option :account

          def show
            <<-HTML
              <div class="panel-heading hbuilt">
                <h1>#{first_name}</h1>
                <p>#{text}</p>
              </div>
            HTML
          end

          private

          def created_on
            cell(::Account::Cell::SignedUp, account)
          end

          def escape(*args)
            ERB::Util.html_escape(*args)
          end

          def text
            t = "#{escape(account.email)} - Account created on #{created_on}"
            t << account.phone_number.number unless account.phone_number.nil?
            t
          end
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

          def offers_table(offers, product)
            content_tag(
              :tr,
              id: "admin_recommend_product_#{product.id}_offers",
              class: "admin_recommend_product_offers",
            ) do
              content_tag :td, colspan: 5 do
                cell(
                  AdminArea::CardProduct::Cell::OffersTable,
                  offers,
                  product: product,
                  person:  person,
                )
              end
            end
          end

          def product_row(product)
            cell(AdminArea::CardRecommendation::Cell::ProductsTable::Row, product)
          end
        end
      end
    end
  end
end
