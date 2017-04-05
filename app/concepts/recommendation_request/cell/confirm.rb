class RecommendationRequest # < RecommendationRequest.superclass
  module Cell
    # @!method self.call(result, options = {})
    #   @option result [Collection<Person>] people with an unconfirmed
    #     rec request. Will raise an error if they don't have one.
    class Confirm < Abroaders::Cell::Base
      extend Abroaders::Cell::Result

      skill :people

      def initialize(result, options = {})
        raise unless result['people'].any?(&:unconfirmed_recommendation_request)
        super
      end

      def show
        "#{main_header} #{cell(ConfirmPerson, collection: people)}"
      end

      private

      def account
        people.first.account
      end

      def main_header
        who = "You're requesting new card recommendations"
        if account.couples?
          names = escape(people.map(&:first_name).join(' and '))
          who << " for #{'both ' if people.size > 2}#{names}"
        end
        who << '.'

        <<-HTML
          <div class="alert alert-info">
            #{who}

            Please check that all your data is up-to-date and click 'Confirm'
            below.
          </div>
        HTML
      end

      class BalanceSummaryTable < Abroaders::Cell::Base
        def show
          %[<table class="table table-striped">
              <thead>
                <th>Name</th>
                <th>Balance</th>
                <th></th>
              </thead>
              <tbody>#{rows}<tbody>
            </table>]
        end

        private

        def rows
          cell(Row, collection: model)
        end

        # @!method self.call(balance, options = {})
        class Row < Abroaders::Cell::Base
          include ActionView::Helpers::NumberHelper

          property :currency_name
          property :value

          private

          def link_to_edit
            link_to 'Edit', '#', class: 'btn btn-xs btn-primary'
          end
        end
      end

      # @!method self.call(card_accounts, options = {})
      class CardSummaryTable < Abroaders::Cell::Base
        def show
          %[<table class="table table-striped">
              <thead>
                <th>Card</th>
                <th>Opened</th>
                <th>Closed</th>
                <th></th>
              </thead>
              <tbody>#{rows}<tbody>
            </table>]
        end

        private

        def rows
          cell(Row, collection: model)
        end

        class Row < Abroaders::Cell::Base
          property :product

          def initialize(card_account, options = {})
            raise 'not a card account' if card_account.opened_on.nil?
            super
          end

          private

          def closed_on
            model.closed_on.nil? ? '-' : model.closed_on.strftime('%b %Y')
          end

          def link_to_edit
            link_to 'Update', edit_card_path(model), class: 'btn btn-xs btn-primary'
          end

          def opened_on
            model.opened_on.strftime('%b %Y') # Dec 2015
          end

          def product_name
            cell(
              CardProduct::Cell::FullName,
              product,
              network_in_brackets: true,
              with_bank: true,
            )
          end
        end
      end

      # @!method self.call(person, options = {})
      #   @param person [Person] person with an unconfirmed rec request. Will
      #     raise an error if they don't have one.
      class ConfirmPerson < Abroaders::Cell::Base
        include Abroaders::Cell::Hpanel
        include Escaped

        def initialize(person, options = {})
          if person.unconfirmed_recommendation_request.nil?
            raise 'person must have an unconfirmed rec request'
          end
          # They shouldn't have a RecReq if they're not eligible, but let's be
          # defensive:
          raise 'person must be eligible' unless person.eligible?
          super
        end

        property :balances
        property :has_partner?
        property :card_accounts
        property :first_name
        property :spending_info

        private

        def balances_summary
          if balances.any?
            <<-HTML
              <p>
                Do you still have all of these loyalty accounts? Is the
                information still up-to-date?
              </p>

              #{cell(BalanceSummaryTable, balances)}

              <p>
                If you have another loyalty program balance that's not on this list,
                #{link_to 'click here to add it', new_person_balance_path(model)}
              </p>
            HTML
          else
            href = new_person_balance_path(model)
            <<-HTML
              <p>
                #{has_partner? ? "#{first_name} doesn't" : "You don't"} have
                any saved loyalty account balances. If this isn't correct,
                #{link_to 'click here to add a new points account', href}
              </p>
            HTML
          end
        end

        def cards_summary
          if card_accounts.any?
            <<-HTML
              <p>
                Do you still have all these cards? Have you closed any of the
                accounts? If any of the information has changed, click 'Edit'
                next to the card, or
                #{link_to 'click here to add a new card', new_card_account_path}
              </p>

              #{cell(CardSummaryTable, card_accounts)}
            HTML
          else
            <<-HTML
              <p>
                #{has_partner? ? "#{first_name} doesn't" : "You don't"} have
                any saved credit or debit cards. If this isn't correct,
                #{link_to 'click here to add a new card', new_card_account_path}
              </p>
            HTML
          end
        end

        def link_to_edit_spending
          link_to(
            'My financial information needs updating',
            edit_person_spending_info_path(model),
            class: 'btn btn-primary btn-small btn-default',
          )
        end

        def spending_info_table
          cell(SpendingInfo::Cell::Table, spending_info, show_eligibility: false)
        end
      end
    end
  end
end
