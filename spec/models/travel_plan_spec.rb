require 'rails_helper'

RSpec.describe TravelPlan do
  let(:travel_plan) { described_class.new }

  it do
    is_expected.to validate_numericality_of(:no_of_passengers)\
      .is_greater_than_or_equal_to(1)\
      .is_less_than_or_equal_to(20)
  end
end
