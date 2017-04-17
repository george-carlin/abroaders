class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    class Banner < Banner.superclass
      # Text that appears at the top of most pages (above the 'request a rec'
      # button if that button is visible). If the user has an unresolved
      # recommendation request, it tells them about it and says that we'll be
      # in touch shortly. Don't bother saying *when* they made the request,
      # because this causes too many complications if there are two people on
      # the account who made requests at different times.
      #
      # If they have recommendations which require action, tell them about that
      # and has a link to /cards.
      #
      # If no-one on the account has any actionable recommendations or
      # recommendation requests, renders an empty string (in future we may
      # change this to output something like 'please tell use when you want a
      # rec' or whatever).
      #
      # If no-one on the account is eligible, will render an empty string
      # (although it shouldn't be called in the first place.)
      #
      # @!method self.call(account, options = {})
      #   @return [String]
      class Status < Abroaders::Cell::Base
        property :couples?
        property :eligible_people
        property :people

        def show
          return '' unless show?
          super
        end

        private

        def names_for(people)
          if couples?
            escape(people.map(&:first_name).join(' and '))
          else
            'You'
          end
        end

        def people
          super.sort_by(&:type).reverse # owner first
        end

        # The string that tells the user about any recommendations they have
        # that require action. This class doesn't calculate whether or not to
        # show the string; it just takes the list of people who have actionable
        # recs and says "NAME(S) (or 'You') has/have recommendations that
        # require action."
        def people_have_actionable_recs
          have = couples? && people_with_actionable_recs.size == 1 ? 'has' : 'have'
          you  = names_for(people_with_actionable_recs)
          "#{you} #{have} card recommendations that require action"
        end

        def people_with_actionable_recs
          @p_w_u_recs ||= people.select(&:actionable_card_recommendations?)
        end

        def people_with_unresolved_reqs
          @p_w_u_reqs ||= people.select(&:unresolved_recommendation_request?)
        end

        def show?
          people.any?(&:eligible?) &&
            (people_with_actionable_recs.any? || people_with_unresolved_reqs.any?)
        end

        # The string that tells the user about any unresolved recommendation
        # requests they've already sent.
        #
        # This class doesn't calculate whether or not to show the string; it
        # just takes the list of people who have unresolved rezs and says "You
        # requested recommendations for (NAMES),
        def you_requested_recs
          result = 'You requested recommendations'
          if people_with_unresolved_reqs.size > 1 || couples?
            result << " for #{names_for(people_with_unresolved_reqs)}"
          end
          result
        end
      end
    end
  end
end
