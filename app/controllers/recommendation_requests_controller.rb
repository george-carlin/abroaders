class RecommendationRequestsController < AuthenticatedUserController
  def confirm
    render cell(
      RecommendationRequest::Cell::Confirm,
      'people' => current_account.people.includes(:cards).where(eligible: true),
    )
  end
end
