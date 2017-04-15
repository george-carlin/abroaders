require 'rails_helper'

RSpec.describe CardAccount::New do
  let(:op) { described_class }

  let(:account) { create(:account) }
  let(:person)  { account.owner }
  let(:product) { create(:product) } # product ID should always be present in the params
  before { allow(account).to receive(:owner).and_return(person) }

  let(:params) { { product_id: product.id } }

  example 'with person_id param' do
    # sets card.person
    result = op.(params.merge(person_id: person.id), 'account' => account)
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end

  example 'with a person ID for the wrong account' do
    other_person = create(:person)
    expect do
      op.(params.merge(person_id: other_person.id), 'account' => account)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  example 'with no person_id param' do
    # sets card.person to account owner
    result = op.(params, 'account' => account)
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end
end
