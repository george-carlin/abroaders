module Abroaders
  module Cell
    # An alert-info that will be shown at the top of most pages when an
    # onboarded account is logged in. It will tell them one of three things
    # related to recommendations (or it might not render anything):
    #
    #   1. You have unresolved recommendations - please visit cards#index
    #   1. You have an unresolved rec request (and we're working on it)
    #   1. Please click here to request a recommendation.
    #
    # Each case is handled by a different subclass.
    #
    # @!method self.call(user, options = {})
    #   @param user [User] the currently logged-in user. May be an account,
    #     an admin, or nil.
    #
    #   Cell will render an empty string if:
    #
    #     1. the user is an admin or nil
    #     1. the user is a non-onboarded account
    #     1. no subclasses of the cell can be found that have anything to
    #        display for the account
    #     1. the current action is blacklisted. e.g. none of the subclasses
    #       should *ever* be shown on rec_reqs#new and #create. The
    #       CR::UnresolvedRecs subclass should not be shown on cards#index.
    #
    #   Subclasses will raise an error if you try to initialize them
    #   with an account that can't be shown.
    class RecommendationAlert < Abroaders::Cell::Base
      include ::Cell::Builder
      include Escaped

      builds do |user|
        if !(user.is_a?(Account) && user.onboarded?)
          Empty
        elsif user.unresolved_card_recommendations?
          CardRecommendation::Cell::UnresolvedAlert
        elsif user.unresolved_recommendation_requests?
          RecommendationRequest::Cell::UnresolvedAlert
        elsif RecommendationRequest::Policy.new(user).create?
          RecommendationRequest::Cell::CallToAction
        else
          Empty
        end
      end

      property :couples?

      def show
        return '' if request_excluded?
        <<-HTML.strip
          <div class="recommendation-alert alert alert-info">
            <div class="recommendation-alert-header">#{header}</div>

            <div class="recommendation-alert-body">
              #{main_text}
            </div>

            <div class="recommendation-alert-actions">
              #{actions}
            </div>
          </div>
        HTML
      end

      BTN_CLASSES = 'btn btn-success'.freeze

      private

      def actions
        ''
      end

      # subclasses can override this, but they should probably call `super` and
      # append to the result rather than overwriting it completely.
      #
      # format:
      # {
      #   'controller_name' => %w['array', 'of', 'action', 'names'],
      # }
      #
      # all names must be strings, not symbols.
      def excluded_actions
        {
          'integrations/award_wallet' => %w[settings callback sync],
          'recommendation_requests' => %w[new create],
        }
      end

      def names_for(people)
        owner_first = people.sort_by(&:type).reverse
        escape!(owner_first.map(&:first_name).join(' and '))
      end

      def request_excluded?
        return false if params.nil? # makes testing easier
        excluded_actions.any? do |ctrlr, actions|
          params['controller'] == ctrlr && actions.include?(params['action'])
        end
      end
    end
  end
end
