class ReadinessController < AuthenticatedUserController
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

    case @readiness.who
    when ReadinessForm::WHO[:both]
      track_intercom_event("obs_ready_own")
      track_intercom_event("obs_ready_com")
    when ReadinessForm::WHO[:owner]
      track_intercom_event("obs_ready_own")
    when ReadinessForm::WHO[:companion]
      track_intercom_event("obs_ready_com")
    else
      raise RuntimeError
    end

    AccountMailer.notify_admin_of_user_readiness_update(@account.id, Time.now.to_i).deliver_later

    set_flash_and_redirect
  end

  def survey
    @account = current_account
    redirect_if_ready_or_ineligible && return
    @readiness_survey = ReadinessSurveyForm.new(account: @account)
  end

  def save_survey
    @account = current_account
    redirect_if_ready_or_ineligible && return
    @readiness_survey = ReadinessSurveyForm.new(account: @account)

    if @readiness_survey.update_attributes(readiness_survey_params)
      @account.people.each do |person|
        track_intercom_event("obs_#{"un" unless person.ready?}ready_#{person.type[0..2]}")
      end

      # reload the account first or onboarding_survey.complete? will return a false negative
      onboarding_survey = current_account.reload.onboarding_survey
      if onboarding_survey.complete?
        AccountMailer.notify_admin_of_survey_completion(
          @account.id, Time.now.to_i
        ).deliver_later
        next_path = root_path
      else
        next_path = onboarding_survey.current_page.path
      end

      redirect_to next_path
    else
      render :survey
    end
  end

  private

  def readiness_params
    params.require(:readiness).permit(:who)
  end

  def readiness_survey_params
    params.require(:readiness_survey).permit(:who, :owner_unreadiness_reason, :companion_unreadiness_reason)
  end

  def redirect_if_ready_or_ineligible
    access =
      if @account.has_companion?
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
