require "rails_helper"

describe SpendingSurvey, type: :model do

  let(:person) { build(:person) }
  let(:survey) { described_class.new(person) }
  subject { survey }

  it { is_expected.to validate_presence_of(:credit_score) }
  it { is_expected.to validate_numericality_of(:credit_score)
              .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350) }

  context "when the person has a business" do
    before { survey.has_business = "with_ein" }
    it { expect(survey).to validate_presence_of(:business_spending_usd) }
    it { expect(survey).to validate_numericality_of(:business_spending_usd)
                                              .is_greater_than_or_equal_to(0) }
  end

  context "when the person does not have business" do
    before { survey.has_business = "no_business" }
    it { expect(survey).not_to validate_presence_of(:business_spending_usd) }
  end

  context "when business spending is invalid" do
    before { survey.has_business = "with_ein" }
    it "has a human-friendly error message" do # bug fix
      expect(survey.tap(&:validate).errors.full_messages).to include \
        "Business spending can't be blank"
    end
  end

end
