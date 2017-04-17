module AdminArea
  module Accounts
    module Operation
      class Index < Trailblazer::Operation
        success :setup_accounts

        private

        def setup_accounts(opts)
          opts['accounts'] = Account.includes(
            people: :spending_info,
            owner: :spending_info,
            companion: :spending_info,
          ).order("email ASC")
        end
      end
    end
  end
end
