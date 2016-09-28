module Estimates
  class BaseEstimate
    include Virtus.model

    attribute :from, Destination
    attribute :to,   Destination
    # "single" or "return"
    attribute :type, String
    # 'economy', 'business_class', or 'first_class'. We don't make estimates for 'premium_economy' tickets.
    attribute :class_of_service, String
    attribute :no_of_passengers, Integer

    def as_json(options={})
      { low: low, high: high }.stringify_keys
    end

    private

    def us_domestic?
      from.region.code == to.region.code && from.region.code == "US"
    end

    def us_international?
      [from.region.code, to.region.code].include?("US")
    end

    def return?
      type == "return"
    end

    def single?
      type == "single"
    end

  end
end
