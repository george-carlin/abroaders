class ReadinessController < AuthenticatedUserController
  def edit
    @account = current_account
    redirect_if_ready_or_ineligible
  end

  def update_both
    @account = current_account
    redirect_if_ready_or_ineligible && return

    update_person!(@account.owner, send_email: false)
    update_person!(@account.companion)

    set_flash_and_redirect
  end

  def update_owner
    @account = current_account
    redirect_if_ready_or_ineligible && return

    update_person!(@account.owner)

    set_flash_and_redirect
  end

  def update_companion
    @account = current_account
    redirect_if_ready_or_ineligible && return

    update_person!(@account.companion)

    set_flash_and_redirect
  end

  private

  def redirect_if_ready_or_ineligible
    redirect_to root_path if @account.ineligible? || @account.ready?
  end

  def update_person!(person, send_email: false)
    person.update!(ready: true)
    track_intercom_event("obs_ready_#{person.type[0..2]}")
    AccountMailer.notify_admin_of_user_readiness_update(@account.id, Time.now.to_i).deliver_later if send_email
  end

  def set_flash_and_redirect
    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end
end
