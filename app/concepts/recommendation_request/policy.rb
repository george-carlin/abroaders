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

      # an account can request recs if at least one person on the account
      # can do so
      #
      # TODO update the logic on who can access the onboarding survey too.
      def create?
        @account.people.any? { |p| Policy.new(p).create? }
      end
    end

    # don't instantiate directly, use Policy instaed
    class ForPerson
      def initialize(person)
        @person = person
      end

      # a person can request a new recommendation iff:
      # 1. they are eligible AND
      # 2 neither they or their partner have have any unresolved recs or rec
      #   requests. (The recs can be actionable, but must be resolved)
      #
      # @return [Boolean]
      def create?
        person.eligible? &&
          !account.unresolved_card_recommendations? &&
          !account.unresolved_recommendation_requests?
      end

      private

      attr_reader :person
      delegate :account, to: :person
    end
  end
end
