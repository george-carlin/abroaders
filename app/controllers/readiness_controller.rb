class ReadinessController < AuthenticatedUserController
  onboard :readiness, with: [:survey, :save_survey]

  def survey
    render cell(Readiness::Cell::Survey, current_account)
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
