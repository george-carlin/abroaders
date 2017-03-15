class RecommendationRequest # < RecommendationRequest.superclass
  module Cell
    class Confirm < Trailblazer::Cell
      extend Abroaders::Cell::Result

      skill :people

      def show
        cell(ConfirmPerson, collection: people)
      end

      class BalanceSummaryTable < Trailblazer::Cell
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
        class Row < Trailblazer::Cell
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
      class CardSummaryTable < Trailblazer::Cell
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

        class Row < Trailblazer::Cell
          property :product

          def initialize(card_account, options = {})
            raise 'not a card account' if card_account.opened_at.nil?
            super
          end

          private

          def closed_at
            model.closed_at.nil? ? '-' : model.closed_at.strftime('%b %Y')
          end

          def link_to_edit
            link_to 'Update', edit_card_path(model), class: 'btn btn-xs btn-primary'
          end

          def opened_at
            model.opened_at.strftime('%b %Y') # Dec 2015
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

      class ConfirmPerson < Trailblazer::Cell
        include Abroaders::Cell::Hpanel
        include Escaped

        def initialize(person, options = {})
          raise 'person must be eligible' unless person.eligible?
          super
        end

        property :balances
        property :card_accounts
        property :first_name
        property :spending_info

        private

        def balances_summary
          cell(BalanceSummaryTable, balances)
        end

        def cards_summary
          cell(CardSummaryTable, card_accounts)
        end

        def link_to_edit_spending
          link_to(
            'My financial information needs updating',
            edit_person_spending_info_path(model),
            class: 'btn btn-primary',
          )
        end

        def spending_info_table
          cell(SpendingInfo::Cell::Table, spending_info)
        end
      end
    end
  end
end
