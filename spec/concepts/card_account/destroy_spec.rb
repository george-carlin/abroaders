require 'rails_helper'

RSpec.describe CardAccount::Destroy do
  let(:op) { described_class }
  let(:account) { create_account }

  let(:card_account) { create_card_account(person: account.owner) }

  example 'destroying a card account' do
    result = op.({ id: card_account.id }, 'current_account' => account)
    expect(result.success?).to be true
    expect(Card.exists?(id: card_account.id)).to be false
  end

  example "attempting to destroy someone else's card account" do
    other_account = create_account
    expect do
      op.({ id: card_account.id }, 'current_account' => other_account)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(Card.exists?(id: card_account.id)).to be true
  end

  example "attempting to destroy a card that's not an account" do
    rec = create_card_recommendation(person: account.owner)
    expect do
      op.({ id: rec.id }, 'current_account' => account)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(Card.exists?(id: card_account.id)).to be true
  end
end
