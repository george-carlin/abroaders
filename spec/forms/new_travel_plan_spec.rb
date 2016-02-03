require "rails_helper"

describe NewTravelPlan do

  let(:user) { create(:user) }
  let(:from) { create(:airport) }
  let(:to)   { create(:airport) }

  # Call 'to_date' to get simple Date classes rather than
  # ActiveSupport::TimeWithZone (since that's what the real form will get in
  # the HTTP request):
  let(:day_0) { 1.day.from_now.to_date }
  let(:day_1) { 2.days.from_now.to_date }
  let(:day_2) { 3.days.from_now.to_date }
  let(:day_3) { 4.days.from_now.to_date }
  let(:day_4) { 5.days.from_now.to_date }

  RSpec::Matchers.define :match_date_range do |expected|

    def is_a_date_range?(range)
      actual.is_a?(Range) && actual.first.is_a?(Date) && actual.last.is_a?(Date)
    end

    match do |actual|
      raise "invalid expected date range" unless is_a_date_range?(expected)

      return false unless is_a_date_range?(actual)

      # Note that the PostgreSQL adapter returns Ranges in the format:
      #
      #   start...(end + 1.day)
      #
      # not:
      #
      #   start..end
      #
      # So to be on the safe side, convert all ranges to the '..' format
      # before comparing:

      if expected.exclude_end?
        expected = (expected.first)..(expected.last - 1.day)
      end

      if actual.exclude_end?
        actual = (actual.first)..(actual.last - 1.day)
      end

      expected == actual
    end
  end

  describe "for a one-way journey" do
    it "saves a valid travel plan" do
      plan = described_class.new(
        user: user,
        type: :single,
        legs: [
          {
            from: from,
            to:   to,
            date_range: day_0..day_1
          }
        ]
      )

      expect(plan).to be_valid

      legs_before = TravelLeg.count
      expect { plan.save! }.to change {TravelPlan.count}.by(1)
      expect(TravelLeg.count).to eq legs_before + 1

      new_plan = TravelPlan.last
      expect(new_plan.user).to eq user
      new_leg = TravelLeg.last
      expect(new_leg.travel_plan).to eq new_plan
      expect(new_leg.from).to eq from
      expect(new_leg.to).to eq to

      expect(new_leg.date_range).to match_date_range(day_0..day_1)
    end

    it "can't have no legs" do
      plan = described_class.new(
        user: user,
        type: :single,
        legs: [ ]
      )
      expect(plan).not_to be_valid
    end

    it "validates legs" do
      plan = described_class.new(
        user: user,
        type: :single,
        legs: [
          {
            from: from,
            to:   from,
            date_range: day_1..day_0
          }
        ]
      )
      expect(plan).not_to be_valid
    end
  end

  describe NewTravelPlan::Leg do
    let(:valid_attrs) do
      {
        from: from,
        to:   to,
        date_range: day_0..day_1
      }
    end
    let(:leg) { described_class.new(valid_attrs) }

    subject { leg }

    it { should be_valid }

    specify "origin and destination can't be the same" do
      leg.to = from
      expect(leg).not_to be_valid
    end

    specify "dates must be in the future" do
      # Both ends of the range in the past:
      leg.date_range = Date.yesterday..Date.yesterday
      expect(leg).not_to be_valid
      leg.date_range = Date.yesterday...Date.today
      expect(leg).not_to be_valid
      # Starts in the past, ends today:
      leg.date_range = Date.yesterday..Date.today
      expect(leg).not_to be_valid
      leg.date_range = Date.yesterday...Date.tomorrow
      expect(leg).not_to be_valid
      # Starts in the past, ends in the future:
      leg.date_range = Date.yesterday..Date.tomorrow
      expect(leg).not_to be_valid
      # Starts and ends today:
      leg.date_range = Date.today..Date.today
      expect(leg).to be_valid
      leg.date_range = Date.today...Date.tomorrow
      expect(leg).to be_valid
      # Starts today, ends in the future:
      leg.date_range = Date.today..Date.tomorrow
      expect(leg).to be_valid
      # Starts and ends in the future:
      leg.date_range = Date.tomorrow..Date.tomorrow
      expect(leg).to be_valid
    end

    specify "dates must be in the right order" do
      leg.date_range = Date.tomorrow..Date.today
      expect(leg).not_to be_valid
    end
  end

end
