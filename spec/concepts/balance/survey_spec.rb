require 'rails_helper'

RSpec.describe Balance::Survey do
  let(:account) { create_account }
  let(:person) { account.owner }
  let(:owner) { person }
  let!(:currencies) { Array.new(3) { create_currency } }
  let(:currency) { currencies.sample }

  before do
    account.update!(onboarding_state: 'owner_balances')
    person.reload
  end

  example 'prepopulating' do
    raise unless Currency.count == 3 # sanity check
    form = described_class.new(person)
    form.prepopulate!
    expect(form.balances.length).to eq 3
  end

  example 'saving' do
    form = described_class.new(person)
    valid = form.validate(balances: [{ value: 3000, currency_id: currency.id }])
    expect(valid).to be true
    expect { form.save }.to change { person.balances.count }.by(1)

    balance = person.balances.last
    expect(balance.value).to eq 3000
    expect(balance.currency).to eq currency
  end

  example 'invalid - negative value' do
    form = described_class.new(person)
    valid = form.validate(balances: [{ value: -1, currency_id: currency.id }])
    expect(valid).to be false
  end

  example 'repopulate after invalid save' do
    form = described_class.new(person)
    form.validate(balances: [{ value: -1, currency_id: currency.id }])
    form.repopulate!
    expect(form.balances.length).to eq 3
    expect(form.balances.detect { |b| b.currency_id == currency.id }.value).to eq(-1)
  end

  example 'invalid - missing value' do
    form = described_class.new(person)
    valid = form.validate(balances: [{ value: nil, currency_id: currency.id }])
    expect(valid).to be false
  end

  example 'saving with no balances' do
    form = described_class.new(person)
    valid = form.validate(balances: [])
    expect(valid).to be true

    expect { form.save }.not_to change { Balance.count }
  end

  describe 'onboarding flow' do
    example 'person is owner and has an eligible companion' do
      account.create_companion!(first_name: 'x', eligible: true)
      form = described_class.new(person)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq 'companion_cards'
    end

    example 'person is owner and has an ineligible companion' do
      account.create_companion!(first_name: 'x', eligible: false)
      form = described_class.new(person)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq 'companion_balances'
    end

    example 'person is eligible owner and has no companion' do
      person.update!(eligible: true)
      form = described_class.new(person)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq 'spending'
    end

    example 'person is ineligible owner and has no companion' do
      person.update!(eligible: false)
      form = described_class.new(person)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq 'phone_number'
    end

    example 'person is companion and eligible' do
      companion = companion!(account, true)
      form = described_class.new(companion)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq 'spending'
    end

    example "person is ineligible companion of eligible owner" do
      person.update!(eligible: true)
      companion = companion!(account, false)
      form = described_class.new(companion)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq "spending"
    end

    example "person is ineligible companion of ineligible owner" do
      companion = companion!(account, false)
      form = described_class.new(companion)
      form.validate(balances: [])
      form.save
      expect(account.reload.onboarding_state).to eq "phone_number"
    end

    def companion!(account, eligible)
      account.update!(onboarding_state: 'companion_balances')
      companion = account.create_companion!(first_name: 'x', eligible: eligible)
      companion
    end
  end
end
