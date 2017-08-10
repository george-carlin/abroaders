require 'rails_helper'

RSpec.describe Balance::Update do
  let(:account) { create_account(:onboarded) }
  let(:owner) { account.owner }
  let(:balance) { create_balance(value: 1234, person: owner) }

  let(:op) { described_class }

  example 'updating value' do
    result = op.(
      {
        balance: { value: 4321 },
        id: balance.id,
      },
      'current_account' => account,
    )
    expect(result.success?).to be true

    balance.reload
    expect(balance.value).to eq 4321
    expect(balance).to eq result['model']
  end

  example 'invalid update' do
    result = op.(
      {
        balance: { value: -1 },
        id: balance.id,
      },
      'current_account' => account,
    )
    expect(result.success?).to be false
    expect(balance.reload.value).to eq 1234
  end

  example 'trying to update someone else\'s balance' do
    expect do
      op.(
        {
          balance: { value: -1 },
          id: balance.id,
        },
        'current_account' => create_account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  example 'trying to update to an invalid person' do
    other_person = create_account.owner
    expect do
      op.(
        {
          balance: { person_id: other_person.id },
          id: balance.id,
        },
        'current_account' => create_account,
      )
    end.to raise_error { ActiveRecord::RecordNotFound }
  end

  describe 'couples account' do
    let(:account) { create_account(:onboarded, :couples) }
    let(:companion) { account.companion }

    example 'changing person' do
      result = op.(
        {
          balance: { person_id: companion.id },
          id: balance.id,
        },
        'current_account' => account,
      )

      expect(result.success?).to be true

      balance.reload
      expect(balance.person).to eq companion
    end

    example 'trying to update to an invalid person' do
      other_person = create_account.owner
      expect do
        op.(
          {
            balance: { person_id: other_person.id },
            id: balance.id,
          },
          'current_account' => create_account,
        )
      end.to raise_error { ActiveRecord::RecordNotFound }
    end
  end
end
