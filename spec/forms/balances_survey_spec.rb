require "rails_helper"

RSpec.describe BalancesSurvey do
  let(:person)  { create(:person) }
  let(:account) { person.account }
  before { account.update!(onboarding_state: "owner_balances") }
  let(:currency) { create_currency }

  example "saving" do
    survey = described_class.new(person: person)
    survey.assign_attributes(
      [{ value: 3000, currency_id: currency.id }],
    )
    expect { survey.save! }.to change { person.balances.count }.by(1)

    balance = person.balances.last
    expect(balance.value).to eq 3000
  end

  describe "onboarding flow" do
    example "person is owner and has an eligible companion" do
      create(:companion, :eligible, account: account)
      survey = described_class.new(person: person)
      survey.save!
      expect(account.reload.onboarding_state).to eq "companion_cards"
    end

    example "person is owner and has an ineligible companion" do
      create(:companion, account: account)
      survey = described_class.new(person: person)
      survey.save!
      expect(account.reload.onboarding_state).to eq "companion_balances"
    end

    example "person is eligible owner and has no companion" do
      person.update!(eligible: true)
      survey = described_class.new(person: person)
      survey.save!
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible owner and has no companion" do
      person.update!(eligible: false)
      survey = described_class.new(person: person)
      survey.save!
      expect(account.reload.onboarding_state).to eq "phone_number"
    end

    example "person is companion and eligible" do
      companion = create(:companion, :eligible, account: account)
      account.update!(onboarding_state: "companion_balances")
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible companion of eligible owner" do
      companion = create(:companion, account: account)
      account.update!(onboarding_state: "companion_balances")
      person.update!(eligible: true)
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible companion of ineligible owner" do
      companion = create(:companion, account: account)
      account.update!(onboarding_state: "companion_balances")
      person.update!(eligible: false)
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "phone_number"
    end
  end
end
