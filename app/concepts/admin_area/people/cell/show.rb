module AdminArea
  module People
    module Cell
      # @!method self.call(person, opts = {})
      #   @param person [Person]
      #   @option option [Collection<CardProduct>] card_products all card
      #     products which have at least one recommendable offer.
      class Show < Abroaders::Cell::Base
        include Escaped
        include Integrations::AwardWallet::Links

        property :account
        property :balances
        property :first_name
        property :home_airports
        property :partner
        property :partner_first_name
        property :recommendation_notes
        property :regions_of_interest
        property :travel_plans
        property :unresolved_recommendation_request
        property :unresolved_recommendation_request?

        option :card_products

        # The cell that renders an individual travel plan.
        def self.travel_plan_cell
          TravelPlan::Cell::Summary
        end

        alias title first_name

        private

        def award_wallet_connection
          return '' unless account.award_wallet?
          awu  = account.award_wallet_user
          name = escape!(awu.user_name)
          link = link_to('View accounts on AwardWallet', admin_award_wallet_account_list_url(awu))
          "User has connected their AwardWallet account <b>#{name}</b>. #{link}"
        end

        def award_wallet_email
          cell(AwardWalletEmail, model)
        end

        def balances_list
          cell(People::Cell::Balances, model)
        end

        def bank_filter_panels
          cell(Banks::Cell::FilterPanel, Bank.alphabetical)
        end

        def card_accounts
          cell(self.class::CardAccounts, model)
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

        def card_recommendations
          cell(self.class::CardRecommendations, model)
        end

        def heading
          cell(Heading, model)
        end

        # If the account has any home airports, list them.
        # Else display text saying there are no home airports.
        def home_airports_list
          if home_airports.any?
            '<h3>Home Airports</h3>' +
              cell(HomeAirports::Cell::List, home_airports).()
          else
            'User has not added any home airports'
          end
        end

        # list the offers that can be recommended to the current user, grouped
        # by their product
        def recommendable_offers
          cell(RecommendationTable, card_products, person: model)
        end

        def recommendation_notes
          # Avoid clashing with the module AdminArea::RecommendationNotes
          cell(Cell::Show::RecommendationNotes, model)
        end

        # If the account has any ROIs,  list them.
        # Else display text saying there are no ROIs.
        def regions_of_interest_list
          if regions_of_interest.any?
            '<h3>Regions of Interest</h3>' +
              cell(RegionsOfInterest::Cell::List, regions_of_interest).()
          else
            'User has not added any regions of interest'
          end
        end

        def spending_info
          cell(People::Cell::SpendingInfo, model, account: account)
        end

        def spend_filter_input
          number_field_tag :card_spend_filter, nil, placeholder: 'Max. spend', min: 0
        end

        def travel_plans_list
          return 'User has no upcoming travel plans' if travel_plans.none?
          '<h3>Travel Plans</h3>' << content_tag(:div, class: 'account_travel_plans') do
            cell(self.class.travel_plan_cell, collection: travel_plans, editable: false)
          end
        end

        # @return true iff *either* person on the account has an unresolved
        #   request, not just the current person
        def account_unresolved_recommendation_requests?
          account.unresolved_recommendation_requests?
        end

        def partner_unresolved_recommendation_request
          partner&.unresolved_recommendation_request
        end

        def partner_unresolved_recommendation_request?
          !!partner_unresolved_recommendation_request
        end

        # @param model [Person]
        class AwardWalletEmail < Abroaders::Cell::Base
          include Escaped

          property :award_wallet_email

          def show
            return '' if award_wallet_email.nil?
            "<p><b>AwardWallet email:</b> #{award_wallet_email}</p>"
          end
        end

        # @!method self.call(person, opts = {})
        #   @param person [Person]
        class Heading < Abroaders::Cell::Base
          include Escaped

          property :first_name
          property :partner
          property :partner?
          property :partner_first_name
          property :email
          property :signed_up_at
          property :owner?
          property :phone_number

          def show
            <<-HTML
              <div class="panel-heading hbuilt">
                <div class="row">
                  <div class="col-xs-12 col-md-9">
                    <h1>#{first_name} <small>#{email}</small></h1>
                  </div>

                  <div class="col-xs-12 col-md-3">
                    #{signed_up}
                    #{phone_number}
                    #{owner}
                    #{companion}
                  </div>
                </div>
              </div>
            HTML
          end

          private

          def signed_up
            "<p>Account created on #{signed_up_at.strftime('%D')}</p>"
          end

          def link_to_self
            link_to first_name, admin_person_path(model)
          end

          def link_to_partner
            link_to partner_first_name, admin_person_path(partner)
          end

          def owner
            "<p>Owner: #{owner? ? link_to_self : link_to_partner}</p>"
          end

          def companion
            return '' unless partner?
            "<p>Companion: #{owner? ? link_to_partner : link_to_self}</p>"
          end

          def phone_number
            number = super
            number.present? ? "<p>#{number}</p>" : ''
          end
        end

        # the <table> of available products and offers that can be recommended.
        #
        # Every odd-numbered <tr> shows information about the product. Every
        # even-numbered <tr> contains a nested <table> that lists all the
        # recommendable offers for that product.
        #
        # @!method self.call(person, opts = {})
        #   @person [Collection<CardProduct>] card_products the CardProducts with
        #     offers that can be recommended
        #   @option options [Person] person
        class RecommendationTable < Abroaders::Cell::Base
          option :person

          private

          def rows
            cell(ProductRows, collection: model, person: person)
          end

          # Two <tr>s, one with the product information and one with its offers
          #
          # @!method self.call(card_product, options = {})
          class ProductRows < Abroaders::Cell::Base
            property :id

            option :person

            def show
              product_row.to_s << offers_row
            end

            private

            def product_row
              cell(AdminArea::CardRecommendations::Cell::ProductsTable::Row, model)
            end

            def offers_row
              content_tag(
                :tr,
                id: "admin_recommend_product_#{id}_offers",
                class: "admin_recommend_product_offers",
              ) do
                content_tag :td, colspan: 5 do
                  cell(CardProducts::Cell::OffersTable, model, person: person)
                end
              end
            end
          end
        end
      end
    end
  end
end
