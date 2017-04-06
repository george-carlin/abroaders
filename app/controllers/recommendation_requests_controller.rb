class RecommendationRequestsController < AuthenticatedUserController
  def create
    run RecommendationRequest::Create do
      redirect_to confirmation_recommendation_requests_path
      return
    end
    flash[:error] = "Couldn't create a recommendation request"
    redirect_to :back
  end

  # Show the user a summary of their data and ask them to update anything
  # that's innaccurate.
  def confirmation
    people = current_account.people.includes(:cards).select(&:unconfirmed_recommendation_request)
    # TODO check for N+1 issues
    render cell(RecommendationRequest::Cell::Confirmation, 'people' => people)
  end

  # The action triggered when the user clicks 'Confirm' at the bottom of the
  # confirmation page.
  def confirm
    run RecommendationRequest::Confirm do
      flash[:success] = "Request sent! You'll receive some card recommendations shortly"
    end
    redirect_to cards_path
  end
end
