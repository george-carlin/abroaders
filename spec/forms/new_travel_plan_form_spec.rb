require "rails_helper"

describe NewTravelPlanForm, type: :model do
  let(:account) { Account.new }
  let(:form)    { described_class.new(account: account, type: "single") }
  subject { form }

  def errors_on(attr)
    form.tap(&:valid?).errors[attr]
  end

  it { is_expected.to validate_presence_of(:departure_date) }
  it { is_expected.to validate_presence_of(:from) }
  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it do
    is_expected.to validate_numericality_of(:no_of_passengers)\
      .is_greater_than_or_equal_to(1)
      .is_less_than_or_equal_to(TravelPlan::MAX_PASSENGERS)
  end
  it do
    is_expected.to validate_inclusion_of(:type)
      .in_array(%w(return single))
  end
  it do
    is_expected.to validate_length_of(:further_information)
      .is_at_most(500)
  end

  specify "departure date must be present and not in the past" do
    form.departure_date = nil
    expect(errors_on(:departure_date)).to eq ["can't be blank"]
    form.departure_date = Time.zone.yesterday
    expect(errors_on(:departure_date)).to eq ["can't be in the past"]
    form.departure_date = Time.zone.today
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

    specify "return date must be present and not in the past" do
      form.departure_date = nil # so we don't get 'must be later than departure' errors

      form.return_date = nil
      expect(errors_on(:return_date)).to eq ["can't be blank"]
      form.return_date = Time.zone.yesterday
      expect(errors_on(:return_date)).to eq ["can't be in the past"]
      form.return_date = Time.zone.today
      expect(errors_on(:return_date)).to be_empty
    end

    specify "return date must be >= departure" do
      form.departure_date = Time.zone.tomorrow
      form.return_date = Time.zone.today
      expect(errors_on(:return_date)).to eq ["can't be earlier than departure date"]
      form.return_date = Time.zone.tomorrow
      expect(errors_on(:return_date)).to be_empty
    end
  end

  describe "#persist!" do
    let(:airport_0) { create(:airport) }
    let(:airport_1) { create(:airport) }

    it "strips whitespace from further_information" do
      account = form.account = create(:account, onboarding_state: :complete)
      form.from = airport_0.full_name
      form.to   = airport_1.full_name
      form.no_of_passengers = 1
      form.departure_date   = Time.zone.today
      form.further_information = '      something      '
      expect { form.save! }.to change { account.travel_plans.count }.by(1)
      plan = account.travel_plans.last
      expect(plan.further_information).to eq 'something'
    end

    it "saves a blank further_information as nil" do
      account = form.account = create(:account, onboarding_state: :complete)
      form.from = airport_0.full_name
      form.to   = airport_1.full_name
      form.no_of_passengers = 1
      form.departure_date   = Time.zone.today
      form.further_information = '      '
      expect { form.save! }.to change { account.travel_plans.count }.by(1)
      plan = account.travel_plans.last
      expect(plan.further_information).to be nil
    end

    context "when account is not onboarded" do
      it "updates the account's onboarding state" do
        account = create(:account, onboarding_state: :travel_plan)
        form.account = account
        form.from = airport_0.full_name
        form.to   = airport_1.full_name
        form.no_of_passengers = 1
        form.departure_date   = Time.zone.today
        expect { form.save! }.to change { account.travel_plans.count }.by(1)
        account.reload
        expect(account.onboarding_state).to eq "account_type"
      end
    end
  end
end
