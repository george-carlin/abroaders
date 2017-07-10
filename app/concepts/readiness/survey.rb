module Readiness
  # The page on the onboarding survey asks the user if they're ready. (If they
  # have two eligible poeple, it'll ask *which* people on the account are
  # ready.) When they submit the form, an unresolved recommendation request is
  # created for each ready person.
  #
  # We used to have a DB column called 'people.ready' but it doesn't exist
  # anymore.  The 'readiness' language is now only used on the onboarding
  # survey, and it's just a front-end thing; under the hood it's all related to
  # RecommendationRequests.
  #
  # @!method self.call(params, options = {})
  #   @option params [String] person_type 'owner', 'companion', or 'both'.
  #     Raises an ArgumentError if it's something else.
  class Survey < Trailblazer::Operation
    step Wrap(Abroaders::Transaction) {
      success :create_rec_requests
      success :update_onboarding_status
    }

    private

    def create_rec_requests(current_account:, params:, **)
      person_type = params.fetch(:person_type)
      case person_type
      when 'neither'
        # noop
      when 'both', 'owner', 'companion'
        result = RecommendationRequest::Create.(params, 'current_account' => current_account)
        raise 'this should never happen!' if result.failure?
      else
        raise "unrecognised type #{person_type}"
      end
    end

    def update_onboarding_status(current_account:, **)
      Account::Onboarder.new(current_account).add_readiness!
    end
  end
end
