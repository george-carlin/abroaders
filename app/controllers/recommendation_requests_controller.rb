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
    unless %w[owner companion both].include?(params[:person_type])
      raise "unrecognised param '#{params[:person_type]}'"
    end

    people = case params[:person_type]
             when 'both'
               current_account.people.to_a
             when 'owner'
               [current_account.owner]
             when 'companion'
               [current_account.companion]
             end

    # TODO extract all the above to an op. Within the app, make sure that the
    # specified people can actually request a rec.
    #
    # Should also raise an error if they request 'both' or 'companion' when
    # they're on a solo account.

    render cell(RecommendationRequest::Cell::New, 'people' => people)
  end
end
