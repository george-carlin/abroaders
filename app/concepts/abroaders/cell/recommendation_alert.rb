module Abroaders
  module Cell
    class RecommendationAlert < Abroaders::Cell::Base
      # @param user [User] the currently logged-in user. May be an account,
      #   an admin, or nil.
      #
      # Cell will render an empty string if:
      #
      #   1. the user is an admin or nil
      #   1. the user is a non-onboarded account
      #   1. no subclasses of the cell can be found that have anything to
      #      display for the account
      #   1. the current action is blacklisted. e.g. none of the subclasses
      #     should *ever* be shown on rec_reqs#new and #create. The
      #     CR::UnresolvedRecs subclass should not be shown on cards#index.
      #
      # Subclasses will raise an error if you try to initialize them
      # with an account that can't be shown.
      def initialize(user, options = {})
        super
        can_handle_account!
      end

      include ::Cell::Builder

      builds do |account|
        [ # the order of these cells matters!
          CardRecommendation::Cell::UnresolvedAlert,
          RecommendationRequest::Cell::UnresolvedAlert,
          RecommendationRequest::Cell::CallToAction,
        ].detect { |cell| cell.can_handle_account?(account) }
      end

      property :couples?

      def show
        return '' unless show?
        <<-HTML.strip
          <div class="alert alert-info">
            #{header}

            <p style="font-size: 14px;">
              #{main_text}
            </p>

            #{actions}
          </div>
        HTML
      end

      def show?
        # Don't render anything unless one of the subclasses got picked
        # up by Builder. A bit hacky :/
        self.class != RecommendationAlert &&
          model.is_a?(Account) && model.onboarded? && !request_excluded?
      end

      def self.can_handle_account?(_account)
        true
      end

      BTN_CLASSES = 'btn btn-success'.freeze # TODO lg?

      private

      def can_handle_account!
        unless self.class.can_handle_account?(model)
          raise ArgumentError, "can't render #{self.class}"
        end
      end

      def actions
        ''
      end

      # subclasses can override this, but they should probably call `super` and
      # append to the result rather than overwriting it completely.
      #
      # format: {
      #   'controller_name' => %w['array', 'of', 'action', 'names'],
      # }
      #
      # all values must be strings, not symbols.
      def excluded_actions
        { 'recommendation_requests' => %w[new create] }
      end

      def names_for(people)
        owner_first = people.sort_by(&:type).reverse
        escape(owner_first.map(&:first_name).join(' and '))
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
