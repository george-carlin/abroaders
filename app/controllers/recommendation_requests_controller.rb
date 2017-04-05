class RecommendationRequestsController < AuthenticatedUserController
  def confirm
    people = current_account.people.includes(:cards).select(&:unconfirmed_recommendation_request)
    # TODO check for N+1 issues
    render cell(RecommendationRequest::Cell::Confirm, 'people' => people)
  end
end
