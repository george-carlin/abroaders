require "rails_helper"

RSpec.describe CardRecommendation::Representer do
  it 'represents a card recommendation as JSON' do
    bank = Bank.new(
      id: 1,
      business_phone: "800 453-9719",
      name: 'Chase',
      personal_phone: "(888) 609-7805",
    )
    card_product = create(
      :card_product,
      bank_id: bank.id,
      bp: 'personal',
      name: "My awesome card",
      network: 'visa',
    )

    card = Card.new(
      card_product: card_product,
      person: create(:person),
      # Note that these dates, of course, make no sense, and a real card
      # account would never have all of them present:
      recommended_at: "2015-09-10",
      applied_on:     "2015-09-11",
      opened_on:      "2015-09-12",
      closed_on:      "2015-09-14",
      clicked_at:     '2015-09-15 02:34 PM',
      declined_at:    '2015-09-16 01:23 AM',
      denied_at:      "2015-09-17",
      nudged_at:      "2015-09-18",
      called_at:      "2015-09-19",
      redenied_at:    "2015-09-20",
      decline_reason: "something",
    )
    card.save!(validate: false)

    parsed_json = JSON.parse(described_class.new(card).to_json)

    expect(parsed_json.keys).to match_array(
      %w[
        id recommended_at applied_on opened_on closed_on clicked_at
        declined_at denied_at nudged_at called_at redenied_at card_product
        decline_reason
      ],
    )

    expect(parsed_json['recommended_at']).to eq '2015-09-10T00:00:00.000Z'
    expect(parsed_json['applied_on']).to eq     '2015-09-11'
    expect(parsed_json['opened_on']).to eq      '2015-09-12'
    expect(parsed_json['closed_on']).to eq      '2015-09-14'
    expect(parsed_json['clicked_at']).to eq     '2015-09-15T14:34:00.000Z'
    expect(parsed_json['declined_at']).to eq    '2015-09-16T01:23:00.000Z'
    expect(parsed_json['denied_at']).to eq      '2015-09-17T00:00:00.000Z'
    expect(parsed_json['nudged_at']).to eq      '2015-09-18T00:00:00.000Z'
    expect(parsed_json['called_at']).to eq      '2015-09-19T00:00:00.000Z'
    expect(parsed_json['redenied_at']).to eq    '2015-09-20T00:00:00.000Z'
    expect(parsed_json['decline_reason']).to eq 'something'

    product = parsed_json['card_product']

    expect(product.keys).to match_array(%w[name network bp type bank])

    expect(product["name"]).to eq "My awesome card"
    expect(product["network"]).to eq "visa"
    expect(product["bp"]).to eq "personal"

    bank = product["bank"]

    expect(bank.keys).to match_array(%w[name personal_phone business_phone id])

    expect(bank["name"]).to eq "Chase"
    expect(bank["personal_phone"]).to eq "(888) 609-7805"
    expect(bank["business_phone"]).to eq "800 453-9719"
  end
end
