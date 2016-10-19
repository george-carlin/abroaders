require "rails_helper"

shared_examples "a TravelPlan form" do
  def errors_on(attr)
    form.tap(&:valid?).errors[attr]
  end

  it { is_expected.to validate_presence_of(:departure_date) }
  it { is_expected.to validate_presence_of(:from_code) }
  it { is_expected.to validate_presence_of(:to_code) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it do
    is_expected.to validate_numericality_of(:no_of_passengers)
      .is_greater_than_or_equal_to(1)
  end
  it do
    is_expected.to validate_inclusion_of(:type)
      .in_array(["return", "single"])
  end
  it do
    is_expected.to validate_length_of(:further_information)
      .is_at_most(500)
  end

  specify "departure date must be present and not in the past" do
    form.departure_date = nil
    expect(errors_on(:departure_date)).to eq ["can't be blank"]
    form.departure_date = Date.yesterday
    expect(errors_on(:departure_date)).to eq ["date can't be in the past"]
    form.departure_date = Date.today
    expect(errors_on(:departure_date)).to be_empty
  end

  describe "#no_of_passengers" do
    it "doesn't show a duplicative error message when blank" do
      form.no_of_passengers = nil
      expect(errors_on(:no_of_passengers)).to eq ["can't be blank"]
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
      form.departure_date = nil # so we don't get 'must be later than departure' errors

      form.return_date = nil
      expect(errors_on(:return_date)).to eq ["can't be blank"]
      form.return_date = Date.yesterday
      expect(errors_on(:return_date)).to eq ["date can't be in the past"]
      form.return_date = Date.today
      expect(errors_on(:return_date)).to be_empty
    end

    specify "return date must be >= departure" do
      form.departure_date = Date.tomorrow
      form.return_date = Date.today
      expect(errors_on(:return_date)).to eq ["date can't be earlier than departure date"]
      form.return_date = Date.tomorrow
      expect(errors_on(:return_date)).to be_empty
    end
  end
end

describe NewTravelPlanForm, type: :model do
  let(:account) { Account.new }
  let(:form)    { described_class.new(account: account, type: "single") }
  subject { form }

  it_behaves_like "a TravelPlan form"

  describe "#persist!" do
    context "when account is not onboarded" do
      it "updates the account's onboarded_state" do
        account = create(:account, onboarding_state: :travel_plan)
        form.account   = account
        form.from_code = create(:airport).code
        form.to_code   = create(:airport).code
        form.no_of_passengers = 1
        form.departure_date   = Date.today
        expect { form.save! }.to change { account.travel_plans.count }.by(1)
        account.reload
        expect(account.onboarding_state).to eq "account_type"
      end
    end
  end
end

describe EditTravelPlanForm, type: :model do
  skip "need to figure out a better approach for 'edit' form objects" do
    let(:travel_plan) { create(:travel_plan, :return) }
    let(:account) { Account.new }
    let(:form)    { described_class.new(account: account, travel_plan: travel_plan) }
    subject { form }

    it_behaves_like "a TravelPlan form"
  end
end
