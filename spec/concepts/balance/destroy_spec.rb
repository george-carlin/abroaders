require 'rails_helper'

RSpec.describe Balance::Destroy do
  let(:account) { create_account }
  let(:balance) { create_balance(person: account.owner) }
  let(:op) { described_class }

  it 'destroys the balance' do
    result = op.({ id: balance.id }, 'current_account' => account)
    expect(result.success?).to be true
    expect(Balance.find_by(id: balance.id)).to be nil
  end

  it "can't destroy someone else's balance" do
    other_account = create_account
    expect do
      op.({ id: balance.id }, 'current_account' => other_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
