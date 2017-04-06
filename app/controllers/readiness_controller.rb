class ReadinessController < AuthenticatedUserController
  onboard :readiness, with: [:survey, :save_survey]

  def edit
    @account = current_account
    @readiness = ReadinessForm.new(account: @account)
    redirect_if_ready_or_ineligible
  end

  def update
    @account = current_account
    redirect_if_ready_or_ineligible && return
    @readiness = ReadinessForm.new(account: @account)
    @readiness.update_attributes!(readiness_params)

    AccountMailer.notify_admin_of_user_readiness_update(@account.id, Time.now.to_i).deliver_later

    set_flash_and_redirect
  end

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

  private

  def readiness_params
    params.require(:readiness).permit(:who)
  end

  def redirect_if_ready_or_ineligible
    # TODO this is crying out to be extracted into some kind of 'policy object'
    access =
      if @account.couples?
        (@account.owner.unready? && @account.owner.eligible?) || (@account.companion.unready? && @account.companion.eligible?)
      else
        @account.owner.unready? && @account.owner.eligible?
      end

    redirect_to root_path unless access
  end

  def set_flash_and_redirect
    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end
end
