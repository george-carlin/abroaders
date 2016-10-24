module Estimates
  class FullEstimate
    include Virtus.model

    attribute :from, Destination
    attribute :to,   Destination
    # "single" or "return"
    attribute :type, String
    attribute :no_of_passengers, Integer

    def self.load(params)
      new(
        from: Country.find_by_code!(params[:from_code].upcase),
        to:   Country.find_by_code!(params[:to_code].upcase),
        type: params[:type],
        no_of_passengers: params[:no_of_passengers].to_i,
      )
    end

    # as_json methods must accept an opts parameter, but we don't use it here
    def as_json(_ = {})
      {
        from: from.code,
        to:   to.code,
        points: {
          economy:        PointsEstimate.new(attributes.merge(class_of_service: "economy")),
          business_class: PointsEstimate.new(attributes.merge(class_of_service: "business_class")),
          first_class:    PointsEstimate.new(attributes.merge(class_of_service: "first_class")),
        },
        fees: {
          economy:        FeesEstimate.new(attributes.merge(class_of_service: "economy")),
          business_class: FeesEstimate.new(attributes.merge(class_of_service: "business_class")),
          first_class:    FeesEstimate.new(attributes.merge(class_of_service: "first_class")),
        },
      }.stringify_keys
    end
  end
end
