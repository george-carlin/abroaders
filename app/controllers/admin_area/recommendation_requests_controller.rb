module AdminArea
  class RecommendationRequestsController < AdminController
    def index
      # accounts with unresolved recs:
      accounts = Account\
                 .joins(:unresolved_recommendation_requests)\
                 .includes(
                   :unresolved_recommendation_requests,
                   owner: :unresolved_recommendation_request,
                   companion: :unresolved_recommendation_request,
                 ).sort_by do |a|
        [
          a.owner.unresolved_recommendation_request&.created_at,
          a.companion&.unresolved_recommendation_request&.created_at,
        ].compact.max
      end
      render cell(RecommendationRequests::Cell::Index, accounts)
    end
  end
end
