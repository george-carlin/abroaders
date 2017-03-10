require 'types'

module Integrations::AwardWallet
  module Owner
    module Operation
      # params:  id:, person_id:
      # account: account
      class UpdatePerson < Trailblazer::Operation
        step :setup_model
        step :set_person
        step :update!

        private

        def setup_model(opts, account:, params:, **)
          opts['model'] = account.award_wallet_owners.find(params.fetch(:id))
        end

        def set_person(opts, account:, params:, **)
          # we do this so that blank strings will be cast to nil
          p_id = Types::Form::Int.(params.fetch(:person_id))
          # raise an error if the person isn't found on the current account
          opts['person'] = p_id.nil? ? nil : account.people.find(p_id)
          true
        end

        def update!(model:, person:, **)
          model.update!(person: person)
        end
      end
    end
  end
end
