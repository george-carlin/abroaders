require "rails_helper"

describe SpendingInfo do

  let(:info) { described_class.new }

  it { is_expected.to validate_presence_of(:credit_score) }
  it { is_expected.to validate_numericality_of(:credit_score)
              .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350) }

  context "when the person has a business" do
    before { info.has_business = "with_ein" }
    it { expect(info).to validate_presence_of(:business_spending_usd) }
    it { expect(info).to validate_numericality_of(:business_spending_usd)
                                              .is_greater_than_or_equal_to(0) }
  end

  context "when the person does not have business" do
    before { info.has_business = "no_business" }
    it { expect(info).not_to validate_presence_of(:business_spending_usd) }
  end

end
