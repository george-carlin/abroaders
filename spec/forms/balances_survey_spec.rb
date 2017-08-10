require "rails_helper"

RSpec.describe BalancesSurvey do
  let(:account) { create_account }
  let(:person) { account.owner }
  let(:owner) { person }
  let(:currency) { create_currency }

  before do
    account.update!(onboarding_state: 'owner_balances')
    person.reload
  end

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
      account.create_companion!(first_name: 'x', eligible: true)
      survey = described_class.new(person: person)
      survey.save!
      expect(account.reload.onboarding_state).to eq "companion_cards"
    end

    example "person is owner and has an ineligible companion" do
      account.create_companion!(first_name: 'x', eligible: false)
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
      companion = companion!(account, true)
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible companion of eligible owner" do
      companion = companion!(account, false)
      owner.update!(eligible: true)
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible companion of ineligible owner" do
      companion = companion!(account, false)
      survey = described_class.new(person: companion)
      survey.save!
      expect(account.reload.onboarding_state).to eq "phone_number"
    end

    def companion!(account, eligible)
      account.update!(onboarding_state: 'companion_balances')
      companion = account.create_companion!(first_name: 'x', eligible: eligible)
      companion
    end
  end
end
