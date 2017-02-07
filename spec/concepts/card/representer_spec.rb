require 'rails_helper'

RSpec.describe Card::Representer do
  example 'to_json' do
    card = Card.new(
      id: 1,
      closed_on: Date.new(2016, 3, 2),
      opened_on: Date.new(2014, 1, 2),
      offer_id: 2,
      product_id: 3,
      created_at: Time.now,
      updated_at: Time.now,
    )
    represented = described_class.new(card).as_json
    expect(represented.keys).to match_array(
      %w[
        closed_on created_at id offer_id opened_on person_id product_id
        updated_at
      ],
    )

    expect(represented['id']).to eq 1

    expect(represented['closed_on']).to eq '2016-03-02'
    expect(represented['offer_id']).to eq 2
    expect(represented['opened_on']).to eq '2014-01-02'
    expect(represented['product_id']).to eq 3
  end
end
