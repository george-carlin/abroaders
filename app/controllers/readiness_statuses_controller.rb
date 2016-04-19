class ReadinessStatusesController < NonAdminController
  before_action :redirect_if_account_type_not_selected!

  def new
    @person = load_person
    redirect_if_ineligible! and return
    redirect_if_already_ready! and return
    @status = @person.build_readiness_status(ready: true)
  end

  def create
    @person = load_person
    redirect_if_already_ready! and return
    @status = @person.build_readiness_status(readiness_status_params)
    if @status.save
      redirect_to after_save_path
    else
      render "new"
    end
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

  def redirect_if_ineligible!
    redirect_to root_path and return true unless @person.eligible_to_apply?
  end

  def after_save_path
    if !@person.main? || !(partner = current_account.companion)
      root_path
    elsif partner.eligible_to_apply?
      new_person_spending_info_path(partner)
    else
      survey_person_balances_path(partner)
    end
  end
end
