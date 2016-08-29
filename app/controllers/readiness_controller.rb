class ReadinessController < AuthenticatedUserController
  include EventTracking

  def show
    @person = load_person
    if @person.ineligible || @person.ready?
      redirect_to root_path
    end
  end

  # TODO make sure that this can only be accessed when the user is not already
  # ready.
  def update
    person = load_person
    person.ready = true
    person.save!

    track_intercom_event("obs_ready_#{person.type[0..2]}")

    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def readiness_params
    params.require(:person).permit(:ready, :unreadiness_reason)
  end

end
