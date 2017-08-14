require 'rails_helper'

RSpec.describe Balance::Create do
  let(:op) { described_class }
  let(:currency) { create_currency }
  let(:account) { create_account(:onboarded) }
  let(:person) { account.owner }
  let(:owner) { person }

  example 'valid save - solo account' do
    # no need to specify the person_id
    expect do
      result = op.(
        {
          balance: {
            currency_id: currency.id,
            value: 1,
          },
        },
        'current_account' => account,
      )
      expect(result.success?).to be true

      balance = result['model']
      expect(balance).to be_persisted
      expect(balance.value).to eq 1
      expect(balance.currency).to eq currency
    end.to change { person.balances.count }.by(1)
  end

  example 'invalid save' do
    expect do
      result = op.(
        {
          balance: {
            currency_id: currency.id,
            person_id: person.id,
            value: -1,
          },
        },
        'current_account' => account,
      )
      expect(result.success?).to be false
    end.not_to change { Balance.count }
  end

  describe 'couples account' do
    let(:account) { create_account(:couples, :onboarded) }
    let(:companion) { account.companion }

    example 'valid save - couples account' do
      expect do
        result = op.(
          {
            balance: {
              currency_id: currency.id,
              value: 1,
              person_id: companion.id,
            },
          },
          'current_account' => account,
        )
        expect(result.success?).to be true

        balance = result['model']
        expect(balance).to be_persisted
        expect(balance.person).to eq companion
        expect(balance.value).to eq 1
        expect(balance.currency).to eq currency
      end.to change { companion.balances.count }.by(1)
    end

    example 'person from other account' do
      other_person = create_account.owner
      expect do
        op.(
          {
            balance: {
              currency_id: currency.id,
              person_id: other_person.id,
              value: -1,
            },
          },
          'current_account' => account,
        )
      end.to raise_error { ActiveRecord::RecordNotFound }
    end
  end
end
