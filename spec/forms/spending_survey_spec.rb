require "rails_helper"

describe SpendingSurvey, type: :model do

  let(:account) do
    acc = Account.new(onboarding_stage: "spending")
    acc.build_main_passenger
    if has_companion
      acc.build_companion
      allow(acc.companion).to receive(:persisted?).and_return(true)
    end
    acc.shares_expenses = shares_expenses
    acc
  end

  let(:shares_expenses) { false }
  let(:has_companion) { false }

  let(:survey)  { described_class.new(account) }
  subject { survey }

  it { is_expected.to validate_presence_of(:main_passenger_credit_score) }
  it { is_expected.to validate_presence_of(:main_passenger_personal_spending) }

  it { is_expected.to validate_numericality_of(:main_passenger_credit_score)
              .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350) }
  it { is_expected.to validate_numericality_of(:main_passenger_personal_spending)
                                            .is_greater_than_or_equal_to(0) }

  it { is_expected.not_to validate_presence_of(:shared_spending) }

  context "when main passenger has a business" do
    before { survey.main_passenger_has_business = "with_ein" }
    it { is_expected.to validate_presence_of(:main_passenger_business_spending) }
    it { is_expected.to validate_numericality_of(:main_passenger_business_spending)
                                                      .is_greater_than_or_equal_to(0) }
  end

  context "when main passenger does not have business" do
    before { survey.main_passenger_has_business = "no_business" }
    it { is_expected.not_to validate_presence_of(:main_passenger_business_spending) }
  end

  context "when account does not have a companion" do
    let(:has_companion) { false }
    it { is_expected.not_to validate_presence_of(:companion_business_spending) }
    it { is_expected.not_to validate_presence_of(:companion_credit_score) }
    it { is_expected.not_to validate_presence_of(:companion_has_business) }
    it { is_expected.not_to validate_presence_of(:companion_personal_spending) }
  end

  context "when account has a companion" do
    let(:has_companion) { true }

    it { is_expected.to validate_presence_of(:companion_credit_score) }

    it { is_expected.to validate_numericality_of(:companion_credit_score)
                .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350) }

    context "and the passengers share expenses" do
      let(:shares_expenses) { true }
      it { is_expected.not_to validate_presence_of(:companion_personal_spending) }
      it { is_expected.not_to validate_presence_of(:main_passenger_personal_spending) }
      it { is_expected.to validate_presence_of(:shared_spending) }
      it { is_expected.to validate_numericality_of(:shared_spending)
                                              .is_greater_than_or_equal_to(0) }
    end

    context "and the passengers don't share expenses" do
      let(:shares_expenses) { false }
      it { is_expected.to validate_presence_of(:companion_personal_spending) }
      it { is_expected.to validate_numericality_of(:companion_personal_spending)\
                                              .is_greater_than_or_equal_to(0) }

      it { is_expected.to validate_presence_of(:main_passenger_personal_spending) }
      it { is_expected.not_to validate_presence_of(:shared_spending) }
    end

    context "and companion has a business" do
      before { survey.companion_has_business = "with_ein" }
      it { is_expected.to validate_presence_of(:companion_business_spending) }
      it { is_expected.to validate_numericality_of(:companion_business_spending)\
                                              .is_greater_than_or_equal_to(0) }
    end

    context "and companion does not have a business" do
      before { survey.companion_has_business = "no_business" }
      it { is_expected.not_to validate_presence_of(:companion_business_spending) }
    end
  end

end
