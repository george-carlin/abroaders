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

        def show # placeholder
          return '' unless show?
          super
        end

        private

        def show?
          people.any?(&:eligible?) &&
            (people_with_actionable_recs.any? || people_with_unresolved_reqs.any?)
        end

        def people # make sure people are always ordered owner first:
          super.sort_by { |p| p.owner ? 0 : 1 }
        end

        def people_have_actionable_recs
          cell(PeopleHaveActionableRecs, people_with_actionable_recs, use_name: couples?)
        end

        def people_with_actionable_recs
          @p_w_u_recs ||= people.select(&:actionable_card_recommendations?)
        end

        def people_with_unresolved_reqs
          @p_w_u_reqs ||= people.select(&:unresolved_recommendation_request?)
        end

        def you_requested_recs
          cell(PeopleHaveUnresolvedReqs, people_with_unresolved_reqs, use_name: couples?)
        end

        # @!method self.call(people)
        #   The string that tells the user about any recommendations
        #   they have that require action. This class doesn't calculate
        #   whether or not to show the string; it just takes the list of people
        #   who have actionable recs and says "NAME(S) (or 'You') has/have
        #   recommendations that require action."
        #
        #   @param people [Collection<Person>] the people who have actionable recs
        #   @option use_name [Boolean] whether to use the person's name or to
        #     just say "You". Only relevant if there's just one person; if
        #     there are two people we always use their names.
        class PeopleHaveActionableRecs < Abroaders::Cell::Base
          property :size
          option :use_name

          def show
            if size > 1
              names = escape(model.map(&:first_name).join(' and '))
              have = 'have'
            else
              names = use_name ? escape(model[0].first_name) : 'You'
              have  = use_name ? 'has' : 'have'
            end
            "#{names} #{have} card recommendations that require action"
          end
        end

        class PeopleHaveUnresolvedReqs < Abroaders::Cell::Base
          property :size
          option :use_name

          def show
            result = 'You requested recommendations'
            if size > 1 || use_name
              result << " for #{escape(model.map(&:first_name).join(' and '))}"
            end
            result
          end
        end
      end
    end
  end
end
