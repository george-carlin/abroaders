class SpendingInfo < SpendingInfo.superclass
  module Cell
    # @option options [Boolean] show_eligibility (default true)
    #   setting this to false hides both eligibility and readiness, but I'm
    #   keeping 'show_eligibility' as the name because we'll be replacing the
    #   whole concept of 'readiness' with rec requests soon.
    class Table < Abroaders::Cell::Base
      property :business_spending_usd
      property :credit_score
      property :has_business
      property :person
      property :will_apply_for_loan

      option :show_eligibility, default: true

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

      def eligibility
        if person.eligible?
          'Yes'
        else
          person.eligible.nil? ? 'Unknown' : 'No'
        end
      end

      def readiness
        person.ready ? 'Ready' : 'Not ready'
      end
    end
  end
end
