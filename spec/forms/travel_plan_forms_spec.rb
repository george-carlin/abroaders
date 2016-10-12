require "rails_helper"

shared_examples "a TravelPlan form" do
  it { is_expected.to validate_presence_of(:departure_date) }
  it { is_expected.to validate_presence_of(:from_id) }
  it { is_expected.to validate_presence_of(:to_id) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it { is_expected.to validate_numericality_of(:no_of_passengers)\
                                  .is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_inclusion_of(:type)
                          .in_array(["return", "single"]) }
  it { is_expected.to validate_length_of(:further_information).
      is_at_most(500) }

  specify "departure date must be present and not in the past" do
    def errors; form.tap(&:valid?).errors[:departure_date] end

    form.departure_date = nil
    expect(errors).to eq ["can't be blank"]
    form.departure_date = Date.yesterday
    expect(errors).to eq ["date can't be in the past"]
    form.departure_date = Date.today
    expect(errors).to be_empty
  end

  describe "#no_of_passengers" do
    it "doesn't show a duplicative error message when blank" do
      form.no_of_passengers = nil
      errors = form.tap(&:valid?).errors[:no_of_passengers]
      expect(errors).to eq ["can't be blank"]
    end
  end

  context "#departure_date=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.departure_date = "05/08/2016"
        expect(form.departure_date).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.departure_date = date
        expect(form.departure_date).to eq date
      end
    end
  end

  context "#return_date=" do
    let(:date) { Date.parse("2016-05-08") }
    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        form.return_date = "05/08/2016"
        expect(form.return_date).to eq date
      end
    end

    context "when passed a Date" do
      it "sets the attribute" do
        form.return_date = date
        expect(form.return_date).to eq date
      end
    end
  end

  context "when type is single" do
    before { form.type = :single }
    it { expect(form).to validate_absence_of(:return_date) }
  end

  context "when type is return" do
    before { form.type = :return }

    specify "return date must be present and in the future" do
      def errors; form.tap(&:valid?).errors[:return_date] end
      form.departure_date = nil # so we don't get 'must be later than departure' errors

      form.return_date = nil
      expect(errors).to eq ["can't be blank"]
      form.return_date = Date.yesterday
      expect(errors).to eq ["date can't be in the past"]
      form.return_date = Date.today
      expect(errors).to be_empty
    end

    specify "return date must be >= departure" do
      def errors; form.tap(&:valid?).errors[:return_date] end

      form.departure_date = Date.tomorrow
      form.return_date = Date.today
      expect(errors).to eq ["date can't be earlier than departure date"]
      form.return_date = Date.tomorrow
      expect(errors).to be_empty
    end
  end
end

describe NewTravelPlanForm, type: :model do
  let(:account) { Account.new }
  let(:form)    { described_class.new(account: account, type: "single") }
  subject { form }

  it_behaves_like "a TravelPlan form"
end

describe EditTravelPlanForm, type: :model do
  skip "need to figure out a better approach for 'edit' form object" do
    let(:travel_plan) { create(:travel_plan, :return) }
    let(:account) { Account.new }
    let(:form)    { described_class.new(account: account, travel_plan: travel_plan) }
    subject { form }

    it_behaves_like "a TravelPlan form"
  end
end
