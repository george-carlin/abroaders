require 'rails_helper'

RSpec.describe Card::Operation::Destroy do
  let(:op) { described_class }
  let(:account) { create(:account) }
  let(:product) { create(:product) }

  let(:card) do
    run!(
      Card::Operation::Create,
      { card: { opened_on: Date.today }, product_id: product.id },
      'account' => account,
    )['model']
  end

  example 'destroying a card' do
    result = op.({ id: card.id }, 'account' => account)
    expect(result.success?).to be true
    expect(Card.exists?(id: card.id)).to be false
  end

  example "attempting to destroy someone else's card" do
    other_account = create(:account)
    expect do
      op.({ id: card.id }, 'account' => other_account)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(Card.exists?(id: card.id)).to be true
  end
end
