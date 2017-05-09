require 'rails_helper'

RSpec.describe CardProduct::Representer do
  it 'represents a card product as JSON' do
    bank = Bank.new(
      business_phone: '800 453-9719',
      id: 1,
      name: 'Chase',
      personal_phone: '(888) 609-7805',
    )

    product = build(
      :card_product,
      bank: bank,
      name: 'My awesome card',
      network: 'visa',
      personal: true,
    )
    parsed_json = JSON.parse(described_class.new(product).to_json)

    expect(parsed_json.keys).to match_array(%w[name network bp type bank])

    expect(parsed_json['name']).to eq 'My awesome card'
    expect(parsed_json['network']).to eq 'visa'
    expect(parsed_json['bp']).to eq 'personal'

    bank = parsed_json['bank']

    expect(bank.keys).to match_array(%w[name personal_phone business_phone id])

    expect(bank['name']).to eq 'Chase'
    expect(bank['personal_phone']).to eq '(888) 609-7805'
    expect(bank['business_phone']).to eq '800 453-9719'
  end
end
