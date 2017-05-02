require 'rails_helper'

RSpec.describe TravelPlan do
  example '#type=' do
    # it raises an error when you try to set an invalid type
    plan = described_class.new

    [
      'one_way',
      'round_trip',
    ].each do |type|
      expect { plan.type = type }.not_to raise_error
      expect(plan.type).to eq type
    end

    expect { plan.type = 'invalid' }.to raise_error(Dry::Types::ConstraintError)
  end
end
