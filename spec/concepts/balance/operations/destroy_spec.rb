require 'rails_helper'

RSpec.describe Balance::Operations::Destroy do
  let(:account) { create(:account) }
  let(:person) { account.owner }
  let(:currency) { create(:currency) }
  let(:balance) do
    Balance::Operations::Create.(
      { balance: { currency_id: currency.id, value: 1_234_567 } },
      'account' => account,
      'person' => person,
    )['model']
  end
  let(:op) { described_class }

  it 'destroys the balance' do
    result = op.({ id: balance.id }, 'account' => account)
    expect(result.success?).to be true
    expect(Balance.find_by(id: balance.id)).to be nil
  end

  it "can't destroy someone else's balance" do
    other_account = create(:account)
    expect do
      op.({ id: balance.id }, 'account' => other_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
