class ReadinessController < AuthenticatedUserController
  def edit
    @account = current_account
    redirect_if_ready_or_ineligible
  end

  def update
    @account = current_account
    redirect_if_ready_or_ineligible && return
    who = readiness_params[:who]

    case who
    when "both"
      update_person!(@account.owner, send_email: false)
      update_person!(@account.companion)
    when "owner"
      update_person!(@account.owner)
    when "companion"
      update_person!(@account.companion)
    else
      raise RuntimeError
    end

    set_flash_and_redirect
  end

  private

  def readiness_params
    params.require(:readiness).permit(:who)
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

  def update_person!(person, send_email: true)
    person.update!(ready: true)
    track_intercom_event("obs_ready_#{person.type[0..2]}")
    AccountMailer.notify_admin_of_user_readiness_update(@account.id, Time.now.to_i).deliver_later if send_email
  end

  def set_flash_and_redirect
    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end
end
