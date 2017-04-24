require 'rails_helper'

RSpec.describe CardProduct do
  example '.recommendable' do
    # product with no offers:
    create(:product)

    product_with_no_live_offers = create(:product)
    kill_offer(create_offer(product: product_with_no_live_offers))

    product_with_live_offers = create(:product)
    create_offer(product: product_with_live_offers)
    create_offer(product: product_with_live_offers)

    expect(described_class.recommendable).to eq [product_with_live_offers]
  end

  example 'annual_fee=' do
    card_product = described_class.new
    card_product.annual_fee = 123.45
    expect(card_product.annual_fee_cents).to eq 123_45

    # rounding up/down:
    card_product.annual_fee = 123.459
    expect(card_product.annual_fee_cents).to eq 123_46

    card_product.annual_fee = 123.454
    expect(card_product.annual_fee_cents).to eq 123_45

    # #annual_fee= uses the #round method; bear in mind that the behaviour of
    # this method changes in Ruby 2.4:
    #
    # # Ruby 2.3
    # 2.5.round # => 3
    # # Ruby 2.4
    # 2.5.round # => # 2
  end
end
