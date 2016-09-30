require "rails_helper"

describe SpendingSurvey, type: :model do
  describe "validations" do
    before do
      @account = Account.new
      @owner   = @account.build_owner(eligible: true)
      @survey  = SpendingSurvey.new(account: @account)
    end

    subject { @survey }

    it { is_expected.to validate_presence_of(:spending) }
    it do
      is_expected.to validate_numericality_of(:spending)
        .is_greater_than_or_equal_to(0)
    end

    it { is_expected.to validate_presence_of(:owner_credit_score) }
    it do
      is_expected.to validate_numericality_of(:owner_credit_score)
        .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350)
    end

    it "validates business spending when owner has a business" do
      @survey.owner_has_business = "with_ein"
      expect(@survey).to validate_presence_of(:owner_business_spending_usd)
      expect(@survey).to validate_numericality_of(:owner_business_spending_usd)
        .is_greater_than_or_equal_to(0)
      @survey.owner_has_business = "without_ein"
      expect(@survey).to validate_presence_of(:owner_business_spending_usd)
      expect(@survey).to validate_numericality_of(:owner_business_spending_usd)
        .is_greater_than_or_equal_to(0)
      @survey.owner_has_business = "no_business"
      expect(@survey).not_to validate_presence_of(:owner_business_spending_usd)
    end

    example "owner attrs must be absent when owner is ineligible" do
      @survey.account.owner.eligible = false
      expect(@survey).to validate_absence_of :owner_business_spending_usd
      expect(@survey).to validate_absence_of :owner_credit_score
      expect(@survey).to validate_absence_of :owner_has_business
    end

    example "companion attrs must be absent when there is no companion" do
      expect(@survey).to validate_absence_of :companion_business_spending_usd
      expect(@survey).to validate_absence_of :companion_credit_score
      expect(@survey).to validate_absence_of :companion_has_business
    end

    example "companion attrs must be absent when comp is ineligible" do
      @survey.account.build_companion(eligible: false)
      expect(@survey).to validate_absence_of :companion_business_spending_usd
      expect(@survey).to validate_absence_of :companion_credit_score
      expect(@survey).to validate_absence_of :companion_has_business
    end

    context "when there is an eligible companion" do
      before { @survey.account.build_companion(eligible: true) }

      it { is_expected.to validate_presence_of(:companion_credit_score) }
      it do
        is_expected.to validate_numericality_of(:companion_credit_score)
          .is_less_than_or_equal_to(850).is_greater_than_or_equal_to(350)
      end

      it "validates business spending when owner has a business" do
        @survey.companion_has_business = "with_ein"
        expect(@survey).to validate_presence_of(:companion_business_spending_usd)
        expect(@survey).to validate_numericality_of(:companion_business_spending_usd)
          .is_greater_than_or_equal_to(0)
        @survey.companion_has_business = "without_ein"
        expect(@survey).to validate_presence_of(:companion_business_spending_usd)
        expect(@survey).to validate_numericality_of(:companion_business_spending_usd)
          .is_greater_than_or_equal_to(0)
        @survey.companion_has_business = "no_business"
        expect(@survey).not_to validate_presence_of(:companion_business_spending_usd)
      end
    end
  end
end
