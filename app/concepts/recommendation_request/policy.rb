class RecommendationRequest < RecommendationRequest.superclass
  # Policy object. See #6 at
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  class Policy
    # @param person_or_account [Person|Account]
    def initialize(person_or_account)
      decider_class = case person_or_account
                      when Person then ForPerson
                      when Account then ForAccount
                      else raise "unrecognised record #{person_or_account}"
                      end
      @decider = decider_class.new(person_or_account)
    end

    delegate :create?, to: :decider

    private

    attr_reader :decider

    # don't instantiate directly, use Policy instaed
    class ForAccount
      def initialize(account)
        @account = account
      end

      # an account can request recs if EVERYONE on the account can do so.
      #
      # TODO update the logic on who can access the onboarding survey too.
      def create?
        @account.people.all? { |p| Policy.new(p).create? }
      end
    end

    # don't instantiate directly, use Policy instaed
    class ForPerson
      def initialize(person)
        @person = person
      end

      # a person can request a new recommendation iff:
      #   they don't have any unresolved recommendations (recs can be actionable,
      #   but must be resolved)
      #   AND
      #   they don't have an unresolved recommendation request
      #
      # @return [Boolean]
      def create?
        @person.eligible? &&
          @person.unresolved_card_recommendations.none? &&
          !@person.unresolved_recommendation_request?
      end
    end
  end
end
