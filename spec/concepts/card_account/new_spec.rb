require 'rails_helper'

RSpec.describe CardAccount::New do
  let(:op) { described_class }

  let(:account) { create_account }
  let(:person)  { account.owner }
  let(:product) { create(:product) } # product ID should always be present in the params
  before { allow(account).to receive(:owner).and_return(person) }

  example 'with person_id param' do
    # sets card.person
    result = op.(
      { card_product_id: product.id, person_id: person.id },
      'current_account' => account,
    )
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end

  example 'with a person ID for the wrong account' do
    other_person = create_person
    expect do
      op.(
        { card_product_id: product.id, person_id: other_person.id },
        'current_account' => account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  example 'with no person_id param' do
    # sets card.person to account owner
    result = op.({ card_product_id: product.id }, 'current_account' => account)
    expect(result.success?).to be true
    model = result['model']
    expect(model.person).to eq person
  end
end
