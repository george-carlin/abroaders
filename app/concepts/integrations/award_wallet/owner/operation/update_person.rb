module Integrations::AwardWallet
  module Owner
    module Operation
      # params:  id:, person_id:
      # account: account
      class UpdatePerson < Trailblazer::Operation
        step :setup_model
        step :update!

        private

        def setup_model(opts, account:, params:)
          opts['model'] = account.award_wallet_owners.find(params.fetch(:id))
        end

        def update!(account:, model:, params:)
          person = if params[:person_id].nil?
                     nil
                   else # make sure the person belongs to the current account:
                     account.people.find(params.fetch(:person_id))
                   end

          model.update!(person: person)
        end
      end
    end
  end
end
