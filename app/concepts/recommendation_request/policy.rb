class RecommendationRequest < RecommendationRequest.superclass
  # Policy object. See #6 at
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  class Policy
    # @param person [Person]
    def initialize(person)
      @person = person
    end

    # a person can request a new recommendation iff:
    #   they don't have any unresolved recommendations
    #   AND
    #   they don't have any unresolved recommendation requests
    #
    # @return [Boolean]
    def create?
      @person.unresolved_unapplied_card_recommendations.none? &&
        @person.unresolved_recommendation_requests.none?
    end
  end
end
