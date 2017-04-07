class ReadinessController < AuthenticatedUserController
  onboard :readiness, with: [:survey, :save_survey]

  def survey
    # bleargh! extract the view to a cell and put this logic in there. TODO
    @checked = case current_account.eligible_people.count
               when 2 then 'both'
               when 1 then current_account.eligible_people.first.type
               else raise 'this should never happen'
               end
  end

  def save_survey
    # TODO extract to operation
    ApplicationRecord.transaction do
      case params.fetch(:person_type)
      when 'neither'
        # noop
      when 'both', 'owner', 'companion'
        result = run(RecommendationRequest::Create)
        raise 'this should never happen!' if result.failure?
      else
        raise "unrecognised type #{params[:person_type]}"
      end
    end
    Account::Onboarder.new(current_account).add_readiness!
    redirect_to onboarding_survey_path
  end
end
