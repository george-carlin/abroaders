require "rails_helper"

shared_examples "a TravelPlan form" do
  it { is_expected.to validate_presence_of(:earliest_departure) }
  it { is_expected.to validate_presence_of(:from_id) }
  it { is_expected.to validate_presence_of(:to_id) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it { is_expected.to validate_numericality_of(:no_of_passengers)\
                                  .is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_inclusion_of(:type)
                                  .in_array(["return", "single"]) }
  it { is_expected.to validate_length_of(:further_information).
                        is_at_most(500) }

  context "iff earliest departure is in the past" do
    it "is invalid" do
      def errors; form.tap(&:valid?).errors[:earliest_departure] end
      expect(errors).to be_empty
      form.earliest_departure = Date.yesterday.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.earliest_departure = Date.today.strftime("%m/%d/%Y")
      expect(errors).to be_empty
      form.earliest_departure = Date.tomorrow.strftime("%m/%d/%Y")
      expect(errors).to be_empty
    end
  end

  context "#earliest_departure=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.earliest_departure = "05/08/2016"
        expect(form.earliest_departure).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.earliest_departure = date
        expect(form.earliest_departure).to eq date
      end
    end
  end
end

describe NewTravelPlanForm, type: :model do
  let(:account) { Account.new }
  let(:form)    { described_class.new(account: account) }
  subject { form }

  it_behaves_like "a TravelPlan form"
end

describe EditTravelPlanForm, type: :model do
  let(:travel_plan) { create(:travel_plan) }
  let(:form) { described_class.find(travel_plan.id) }
  subject { form }

  it_behaves_like "a TravelPlan form"
end
