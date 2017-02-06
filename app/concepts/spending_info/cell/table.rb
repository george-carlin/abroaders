class SpendingInfo < ApplicationRecord
  module Cell
    class Table < Trailblazer::Cell
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
