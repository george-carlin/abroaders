class SpendingInfo < SpendingInfo.superclass
  module Operation
    # load the data required for the spending_infos#show page. Fails if the
    # account has no eligible people (because if there are no eligible people,
    # there won't be any spending info to show.)
    class Show < Trailblazer::Operation
      step :account_has_any_eligible_people?
      failure :log_error
      step :load_people

      private

      def account_has_any_eligible_people?(account:, **)
        account.people.any?(&:eligible)
      end

      def log_error(opts)
        opts['error'] = 'Account must have at least one eligible person'
      end

      def load_people(opts, account:, **)
        opts['people'] = account.people.includes(:spending_info)
      end
    end
  end
end
