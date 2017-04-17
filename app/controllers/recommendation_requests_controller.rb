class RecommendationRequestsController < AuthenticatedUserController
  def create
    run RecommendationRequest::Create do
      flash[:success] = "Request sent! You'll receive some card recommendations shortly"
      redirect_to cards_path
      return
    end
    flash[:error] = "Couldn't create a recommendation request"
    redirect_to new_recommendation_requests_path(person_type: params[:person_type])
  end

  # Show the user a summary of their data and ask them to update anything
  # that's innaccurate.
  def new
    people = current_account.people_by_type(params.fetch(:person_type))
    render cell(RecommendationRequest::Cell::New, 'people' => people)
  end
end
