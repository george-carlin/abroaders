module Readiness
  class Survey < Trailblazer::Operation
    extend Abroaders::Operation::Transaction

    step wrap_in_transaction {
      success :create_rec_requests
      success :update_onboarding_status
    }

    private

    def create_rec_requests(params:, **)
      person_type = params.fetch(:person_type)
      case person_type
      when 'neither'
        # noop
      when 'both', 'owner', 'companion'
        result = run(RecommendationRequest::Create)
        raise 'this should never happen!' if result.failure?
      else
        raise "unrecognised type #{person_type}"
      end
    end

    def update_onboarding_status(account:, **)
      Account::Onboarder.new(account).add_readiness!
    end
  end
end
