class ReadinessController < AuthenticatedUserController
  include EventTracking

  def show
    @person = load_person
    if @person.ineligible? || @person.ready?
      redirect_to root_path
    end
  end

  def update
    @person = load_person
    redirect_to root_path and return if @person.ineligible? || @person.ready?

    @person.update_attributes!(ready: true)

    track_intercom_event("obs_ready_#{@person.type[0..2]}")

    flash[:success] = "Thanks! You will shortly receive your first card recommendation."
    redirect_to root_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

end
