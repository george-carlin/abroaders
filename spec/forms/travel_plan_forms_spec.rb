require "rails_helper"

shared_examples "a single TravelPlan form" do
  it { is_expected.to validate_presence_of(:depart_on) }
  it { is_expected.to validate_presence_of(:from_id) }
  it { is_expected.to validate_presence_of(:to_id) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it { is_expected.to validate_numericality_of(:no_of_passengers)\
                                  .is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_inclusion_of(:type)
                          .in_array(["return", "single"]) }
  it { is_expected.to validate_length_of(:further_information).
      is_at_most(500) }

  context "and departure date is in the past" do
    it "is invalid" do
      def errors; form.tap(&:valid?).errors[:depart_on] end
      if new_travel_plan?
        expect(errors).not_to be_empty
      else
        expect(errors).to be_empty
      end

      form.depart_on = Date.yesterday.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.depart_on = Date.today.strftime("%m/%d/%Y")
      expect(errors).to be_empty
      form.depart_on = Date.tomorrow.strftime("%m/%d/%Y")
      expect(errors).to be_empty
    end
  end

  context "#depart_on=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.depart_on = "05/08/2016"
        expect(form.depart_on).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.depart_on = date
        expect(form.depart_on).to eq date
      end
    end
  end
end

shared_examples "a return TravelPlan form" do
  it { is_expected.to validate_presence_of(:depart_on) }
  it { is_expected.to validate_presence_of(:from_id) }
  it { is_expected.to validate_presence_of(:to_id) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it { is_expected.to validate_numericality_of(:no_of_passengers)\
                                  .is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_inclusion_of(:type)
                          .in_array(["return", "single"]) }
  it { is_expected.to validate_length_of(:further_information).
      is_at_most(500) }

  context "and departure date is in the past" do
    it "is invalid" do
      def errors; form.tap(&:valid?).errors[:depart_on] end
      if new_travel_plan?
        expect(errors).not_to be_empty
      else
        expect(errors).to be_empty
      end

      form.depart_on = Date.yesterday.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.depart_on = Date.today.strftime("%m/%d/%Y")
      expect(errors).to be_empty
      form.depart_on = Date.tomorrow.strftime("%m/%d/%Y")
      expect(errors).to be_empty
    end
  end

  context "#depart_on=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.depart_on = "05/08/2016"
        expect(form.depart_on).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.depart_on = date
        expect(form.depart_on).to eq date
      end
    end
  end

  context "and return date is in the past" do
    it "is invalid" do
      def errors; form.tap(&:valid?).errors[:return_on] end
      if new_travel_plan?
        expect(errors).not_to be_empty
      else
        expect(errors).to be_empty
      end

      form.depart_on = Date.tomorrow.strftime("%m/%d/%Y")

      form.return_on = Date.yesterday.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.return_on = Date.today.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.return_on = Date.tomorrow.strftime("%m/%d/%Y")
      expect(errors).to be_empty
      form.return_on = 1.week.from_now.strftime("%m/%d/%Y")
      expect(errors).to be_empty
    end
  end

  context "#return_on=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.return_on = "05/08/2016"
        expect(form.return_on).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.return_on = date
        expect(form.return_on).to eq date
      end
    end
  end
end

describe "with single type TravelPlan" do
  describe NewTravelPlanForm, type: :model do
    let(:account) { Account.new }
    let(:form)    { described_class.new(account: account, type: "single") }
    let(:new_travel_plan?) { true }
    subject { form }

    it_behaves_like "a single TravelPlan form"
  end

  describe EditTravelPlanForm, type: :model do
    let(:travel_plan) { create(:travel_plan, :single) }
    let(:form) { described_class.find(travel_plan.id) }
    let(:new_travel_plan?) { false }
    subject { form }

    it_behaves_like "a single TravelPlan form"
  end
end

describe "with return type TravelPlan" do
  describe NewTravelPlanForm, type: :model do
    let(:account) { Account.new }
    let(:form)    { described_class.new(account: account, type: "return") }
    let(:new_travel_plan?) { true }
    subject { form }

    it_behaves_like "a return TravelPlan form"
  end

  describe EditTravelPlanForm, type: :model do
    let(:travel_plan) { create(:travel_plan, :return) }
    let(:form) { described_class.find(travel_plan.id) }
    let(:new_travel_plan?) { false }
    subject { form }

    it_behaves_like "a return TravelPlan form"
  end
end
