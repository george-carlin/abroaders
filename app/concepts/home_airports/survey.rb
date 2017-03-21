require 'dry-types'

module HomeAirports
  # model: an Account
  class Survey < Reform::Form
    include Coercion

    # See https://github.com/trailblazer/reform/wiki/Converting-IDs-into-Models-for-a-HABTM
    #
    # The example there (although it may have been updated by the time you read
    # this since it's a wiki) uses a Virtus::Attribute, but we can get the same
    # effect with dry-types:
    ArrayOfAirports = ::Dry::Types::Definition.new(Array).constructor do |airport_ids|
      ids = airport_ids.map { |id| Types::Form::Int.(id) }.reject(&:nil?)
      Airport.find(ids)
    end

    property :home_airports, type: ArrayOfAirports

    validates :home_airports, presence: true, length: { minimum: 1, maximum: 5 }
  end
end
