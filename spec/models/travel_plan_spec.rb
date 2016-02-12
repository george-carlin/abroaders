require 'rails_helper'

describe TravelPlan do

  let(:travel_plan) { described_class.new }

  it do
    is_expected.to validate_numericality_of(:no_of_passengers)\
      .is_greater_than_or_equal_to(1)\
      .is_less_than_or_equal_to(20)
  end

  describe "flights" do
    def errors; travel_plan.tap(&:valid?).errors[:base] end

    let(:message) do
      t(
        "activerecord.errors.models.travel_plan.attributes.base."\
        "bad_flight_count"
      )
    end

    before { travel_plan.type = type }

    context "when type is 'single'" do
      let(:type) { :single }
      specify "there must be exactly one associated flight" do
        expect(errors).to include message
        travel_plan.flights << Flight.new
        expect(errors).not_to include message
        travel_plan.flights << Flight.new
        expect(errors).to include message
      end
    end

    context "when type is 'return'" do
      let(:type) { :return }
      specify "there must be exactly one associated flight" do
        expect(errors).to include message
        travel_plan.flights << Flight.new
        expect(errors).not_to include message
        travel_plan.flights << Flight.new
        expect(errors).to include message
      end
    end

    context "when type is 'multi'" do
      let(:type) { :multi }
      specify "there must be more than one associated flight" do
        expect(errors).to include message
        travel_plan.flights << Flight.new
        expect(errors).to include message
        travel_plan.flights << Flight.new
        expect(errors).not_to include message
      end
    end
  end

end
