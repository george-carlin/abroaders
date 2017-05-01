class SpendingInfo < SpendingInfo.superclass
  module Operation
    # Pass if the current account is allowed to view the spending#show action.
    # In the future this should maybe be replaced with a Policy object?
    class Show < Trailblazer::Operation
      step :account_has_any_eligible_people?
      failure :log_error

      private

      def account_has_any_eligible_people?(account:, **)
        account.eligible_people.any?
      end

      def log_error(opts)
        opts['error'] = 'Account must have at least one eligible person'
      end
    end
  end
end
