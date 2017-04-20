module Estimates
  class BaseEstimate < Dry::Struct
    attribute :from, Dry::Types['object'] # Destination
    attribute :to, Dry::Types['object'] # Destination
    attribute :type, Types::Strict::String.enum('single', 'return')
    attribute :class_of_service, Types::Strict::String.enum(
      'economy', 'business_class', 'first_class',
    ) # We don't make estimates for 'premium_economy' tickets.
    attribute :no_of_passengers, Types::Strict::Int

    # as_json methods must accept an opts parameter, but we don't use it here
    def as_json(_ = {})
      { 'low' => low, 'high' => high }
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
