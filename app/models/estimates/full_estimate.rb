module Estimates
  class FullEstimate < Dry::Struct
    attribute :from, Dry::Types['object'] # Destination
    attribute :to, Dry::Types['object'] # Destination
    attribute :type, Types::Strict::String.enum('single', 'return')
    attribute :no_of_passengers, Types::Strict::Int

    def self.load(params)
      destination_scope = Destination.includes(parent: { parent: :parent })
      new(
        from: destination_scope.find_by_code!(params[:from_code].upcase),
        to:   destination_scope.find_by_code!(params[:to_code].upcase),
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
          economy: to_points_estimate('economy'),
          business_class: to_points_estimate('business_class'),
          first_class:    to_points_estimate('first_class'),
        },
        fees: {
          economy:        to_fees_estimate('economy'),
          business_class: to_fees_estimate('business_class'),
          first_class:    to_fees_estimate('first_class'),
        },
      }.stringify_keys
    end

    private

    def to_fees_estimate(cos)
      FeesEstimate.new(
        class_of_service: cos,
        from: from,
        no_of_passengers: no_of_passengers,
        to: to,
        type: type,
      )
    end

    def to_points_estimate(cos)
      PointsEstimate.new(
        class_of_service: cos,
        from: from,
        no_of_passengers: no_of_passengers,
        to: to,
        type: type,
      )
    end
  end
end
