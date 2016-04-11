class ReadinessStatusesController < NonAdminController

  def new
    @person = load_person
    redirect_if_already_ready! and return
    @status = @person.build_readiness_status(ready: true)
  end

  def create
    @person = load_person
    redirect_if_already_ready! and return
    @status = @person.build_readiness_status(readiness_status_params)
    if @status.save
      if current_account.people.count > 1
        redirect_to root_path
      else
        redirect_to new_companion_path
      end
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

end
