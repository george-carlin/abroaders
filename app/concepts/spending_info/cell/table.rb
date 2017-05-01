class SpendingInfo < SpendingInfo.superclass
  module Cell
    # @!method self.call(spending_info, options = {})
    class Table < Abroaders::Cell::Base
      property :business_spending_usd
      property :credit_score
      property :has_business
      property :person
      property :will_apply_for_loan

      private

      delegate :account, to: :person

      def business_spending
        cell(::Business::Cell::TableRow, Business.build(model))
      end

      def personal_spending
        cell(::Account::Cell::MonthlySpending::TableRow, account)
      end

      def will_apply_for_loan
        super ? 'Yes' : 'No'
      end

      # TODO why is this here? won't the person always be eligible if they
      # have a spending info?
      def eligibility
        if person.eligible?
          'Yes'
        else
          person.eligible.nil? ? 'Unknown' : 'No'
        end
      end
    end
  end
end
