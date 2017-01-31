require 'rails_helper'

RSpec.describe Card::Operations::New do
  let(:op) { described_class }

  let(:account) { Account.new }
  let(:person) { Person.new(owner: true) }
  before { allow(account).to receive(:owner).and_return(person) }

  example 'with "person" option' do
    # sets card.person
    result = op.({}, 'person' => person, 'account' => account)
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end

  example 'with no "person" option' do
    # sets card.person to account owner
    result = op.({}, 'account' => account)
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end

  example 'when passed a product_id param' do
    product = CardProduct.new
    allow(CardProduct).to receive(:find).with(1).and_return(product)
    result = op.({ product_id: 1 }, 'account' => account)
    expect(result.success?).to be true
    expect(result['product']).to eq product
  end
end
