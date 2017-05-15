require "rails_helper"

RSpec.describe SpendingSurvey, type: :model do
  describe "validations" do
    before do
      @account = Account.new
      @owner   = @account.build_owner(eligible: true)
      @survey  = SpendingSurvey.new(account: @account)
    end

    subject { @survey }

    it { is_expected.to validate_presence_of(:monthly_spending) }
    it do
      is_expected.to validate_numericality_of(:monthly_spending)
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

  example "saving" do
    account = create_account(:eligible, onboarding_state: 'spending')
    survey = described_class.new(account: account)
    survey.monthly_spending = 5000
    survey.owner_credit_score = 500

    expect do
      survey.save!
    end.to change { SpendingInfo.count }.by(1)
    account.reload

    expect(account.owner.spending_info).to be_present

    expect(account.onboarding_state).to eq 'readiness'
  end

  specify 'saving ignores business spending when has_business is false' do
    account = create_account(:couples, :eligible, onboarding_state: 'spending')
    survey = described_class.new(account: account)
    survey.monthly_spending = 5000
    survey.owner_credit_score = survey.companion_credit_score = 500
    survey.owner_has_business = survey.companion_has_business = 'no_business'
    survey.owner_business_spending_usd = survey.companion_business_spending_usd = 12345

    expect do
      survey.save!
    end.to change { SpendingInfo.count }.by(2)
    account.reload

    expect(account.owner.spending_info.business_spending_usd).to be_nil
    expect(account.companion.spending_info.business_spending_usd).to be_nil
  end
end
