class ReadinessStatusesController < AuthenticatedUserController
  before_action :redirect_if_not_onboarded_travel_plans!
  before_action :redirect_if_account_type_not_selected!

  include EventTracking

  def new
    @person = load_person
    redirect_if_ineligible! and return
    redirect_if_already_ready! and return
    redirect_if_readiness_given! and return
    @status = @person.build_readiness_status(ready: true)
  end

  def create
    @person = load_person
    redirect_if_already_ready! and return
    @status = @person.build_readiness_status(readiness_status_params)
    if @status.save
      unless current_account.has_companion? && @person.main?
        #String workaround becauce ActiveJob won't accept Time arguments
        timestamp = Time.now.in_time_zone("EST").to_s
        AccountMailer.notify_admin_of_survey_completion(current_account.id, timestamp).deliver_later
      end

      track_intercom_event("obs_#{"un" if !@status.ready?}ready_#{@person.type[0..2]}")

      redirect_to after_save_path
    else
      render "new"
    end
  end

  def show
    @person = load_person
    redirect_if_ineligible! and return
    redirect_if_already_ready! and return
    redirect_if_readiness_not_given! and return
  end

  # TODO make sure that this can only be accessed when the user is not already
  # ready.
  def update
    person = load_person
    person.readiness_status.ready = true
    person.readiness_status.save!

    track_intercom_event("obs_ready_#{person.type[0..2]}")

    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def readiness_status_params
    params.require(:readiness_status).permit(:ready, :unreadiness_reason)
  end

  def redirect_if_already_ready!
    redirect_to root_path and return true if @person.ready_to_apply?
  end

  def redirect_if_readiness_given!
    redirect_to person_readiness_status_path(@person) and return true if @person.readiness_given?
  end

  def redirect_if_readiness_not_given!
    redirect_to new_person_readiness_status_path(@person) and return true unless @person.readiness_given?
  end

  def redirect_if_ineligible!
    redirect_to root_path and return true unless @person.eligible?
  end

  def after_save_path
    if !@person.main? || !(partner = current_account.companion)
      root_path
    elsif partner.eligible?
      new_person_spending_info_path(partner)
    else
      survey_person_balances_path(partner)
    end
  end
end
