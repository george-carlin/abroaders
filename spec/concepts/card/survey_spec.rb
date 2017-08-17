require 'rails_helper'

RSpec.describe Card::Survey do
  let(:products) { create_list(:card_product, 3) }

  let(:account) { create_account }
  let(:person) { account.owner }

  before do
    account.update!(onboarding_state: 'owner_cards')
    account.reload
  end

  # Example hash contents: {
  #   card_product_id: '3'
  #   opened_on_(1i): '2016'
  #   opened_on_(2i): '1'
  #   closed: 'true'
  #   closed_on_(1i): '2016'
  #   closed_on_(2i): '1'
  # }

  example '' do
    form = described_class.new(person)

    valid = form.validate(
      cards: [
        {
          card_product_id: products[1].id,
          closed: nil,
          'closed_on(1i)' => '2017', # should be ignored
          'closed_on(2i)' => '2',
          'closed_on(3i)' => '1',
          'opened_on(1i)' => '2016',
          'opened_on(2i)' => '1',
          'opened_on(3i)' => '1',
        },
        {
          card_product_id: products[2].id,
          closed: 'true',
          'closed_on(1i)' => '2017',
          'closed_on(2i)' => '2',
          'closed_on(3i)' => '1',
          'opened_on(1i)' => '2015',
          'opened_on(2i)' => '4',
          'opened_on(3i)' => '1',
        },
      ],
    )

    expect(valid).to be true

    expect do
      form.save
    end.to change { person.cards.count }.by(2)

    c_0 = person.cards[0]
    expect(c_0.card_product).to eq products[1]
    expect(c_0.opened_on.year).to eq 2016
    expect(c_0.opened_on.month).to eq 1
    expect(c_0.closed_on).to be_nil

    c_1 = person.cards[1]
    expect(c_1.card_product).to eq products[2]
    expect(c_1.opened_on.year).to eq 2015
    expect(c_1.opened_on.month).to eq 4
    expect(c_1.closed_on.year).to eq 2017
    expect(c_1.closed_on.month).to eq 2
  end
end
